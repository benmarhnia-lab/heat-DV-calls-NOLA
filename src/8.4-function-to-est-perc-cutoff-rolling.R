#' @title calc_perc_cutoff_rolling
#' @description Calculate the rolling percentile for each date and Zip
#' @param DT A data.table or dataframe with columns 'date', 'Zip', and the variable of interest
#' @param var_col The name of the column containing the variable of interest
#' @param ntile The percentile to calculate (default is 0.9)
#' @param num_days The number of days to consider in the rolling window (default is 7)
#' @return The input data.table with an additional column 'percentile' containing the rolling percentile


calc_perc_cutoff_rolling <- function(DT, var_col, new_col, ntile = 0.9, num_days = 7) {
  setkey(DT, date, Zip)
  
  DT[, (new_col) := {
    window_start <- date - days(num_days)
    window_end <- date + days(num_days)
    window_data <- DT[date >= window_start & date <= window_end & Zip == .BY$Zip, get(..var_col)]
    quantile(window_data, probs = ntile, na.rm = TRUE)
  }, by = .(date, Zip)]
  
  return(DT)
}