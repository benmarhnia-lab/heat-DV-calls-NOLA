#' @title calc_roll_perc_parallel
#' @description Calculate the rolling percentile for each date and geographic unit (e.g. Zip/psu)
#' @param DT A data.table or dataframe with columns 'date', 'Zip', and the variable of interest
#' @param var_col The name of the column containing the variable of interest
#' @param ntile The percentile to calculate (default is 0.9)
#' @param num_days The number of days to consider in the rolling window (default is 3)
#' @param psu_col The name of the column containing the geographic unit (default is 'Zip')
#' @return The input data.table with an additional column 'percentile' containing the rolling percentile


calc_roll_perc_parallel <- function(DT, var_col = "tmax", ntile = 0.9, num_days = 3, psu_col = "Zip", num_cores = detectCores() - 1) {
  DT <- as.data.table(DT)
  if (!is.data.table(DT)) {
    stop("Failed to convert DT to a data.table")
  }
  
  # Ensure date column is in Date format
  DT[, date := as.Date(date)]
  
  # calculate month-day
  DT[, month_day := format(date, "%m-%d")]
  
  # Function to get date window
  get_date_window <- function(date, num_days) {
    seq(date - as.difftime(num_days, unit="days"), date + as.difftime(num_days, unit="days"), by = "day")
  }

  # Get unique combinations of date and PSU
  unique_date_psu <- unique(DT[, .(date, PSU = get(psu_col))])
  
  # Create the percentile column name
  perc_col <- paste0("cutoff_roll_", ntile * 100)
  
  # Set up parallel backend
  cl <- makeCluster(num_cores)
  registerDoParallel(cl)
  
  # Parallelize the loop
  results <- foreach(i = 1:nrow(unique_date_psu), .combine = rbind, .packages = c("data.table")) %dopar% {
    current_date <- unique_date_psu$date[i]
    current_psu <- unique_date_psu$PSU[i]
    
    vec_date_window <- get_date_window(current_date, num_days)
    vec_month_day <- format(as.Date(vec_date_window), "%m-%d")
    
    DT2 <- DT[month_day %in% vec_month_day & get(psu_col) == current_psu, 
              .(date, value = get(var_col))]
    
    DT2 <- DT2[date <= as.Date(current_date) + num_days]
    
    if (nrow(DT2) > 0) {
      percentile_value <- quantile(DT2$value, probs = ntile, na.rm = TRUE)
      new_row <- data.table(date = current_date, PSU = current_psu)
      new_row[[perc_col]] <- percentile_value
      new_row
    } else {
      NULL
    }
  }
  
  # Stop the cluster
  stopCluster(cl)
  
  return(results)
}


# Function that works but does not use parallel processing
calc_roll_perc_slow_gen <- function(DT, var_col = "tmax", ntile = 0.9, num_days = 3, psu_col = "Zip") {
  DT <- as.data.table(DT)
  if (!is.data.table(DT)) {
    stop("Failed to convert DT to a data.table")
  }

  # Ensure date column is in Date format
  DT[, date := as.Date(date)]

  # calculate month-day
  DT[, month_day := format(date, "%m-%d")]

  # Function to get date window
  get_date_window <- function(date, num_days) {
    seq(date - as.difftime(num_days, unit="days"), date + as.difftime(num_days, unit="days"), by = "day")
  }

  # Get unique combinations of date and PSU
  unique_date_psu <- unique(DT[, .(date, PSU = get(psu_col))])

  # Create the percentile column name
  perccol <- paste0("cutoff_roll_", ntile * 100)

  # Initialize results data.table
  results <- data.table(date = as.Date(character()), PSU = character())
  results[[perc_col]] <- numeric()

  # Loop through each unique date and PSU combination
  for (i in 1:nrow(unique_date_psu)) {
    current_date <- unique_date_psu$date[i]
    current_psu <- unique_date_psu$PSU[i]
    # current_year <- lubridate::year(current_date)

    vec_date_window <- get_date_window(current_date, num_days)
    vec_month_day <- format(as.Date(vec_date_window), "%m-%d")

    DT2 <- DT[month_day %in% vec_month_day & get(psu_col) == current_psu, 
              .(date, value = get(var_col))]

    DT2 <- DT2[date <= as.Date(current_date) + num_days]

    if (nrow(DT2) > 0) {
      percentile_value <- quantile(DT2$value, probs = ntile, na.rm = TRUE)
      new_row <- data.table(date = current_date, PSU = current_psu)
      new_row[[perc_col]] <- percentile_value
      results <- rbind(results, new_row)
    }
  }

  return(results)
}