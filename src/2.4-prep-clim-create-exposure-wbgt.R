# Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)

# Constants ----
path_processed_data <- here("data", "processed-data")
source(here("src", "8.4-function-to-est-perc-cutoff-rolling.R"))
heat_var <- "wbgt_max"
vec_cutoffs_abs <- c(23, 25, 27)
vec_cutoffs_perc <- c(0.85, 0.90, 0.95)
vec_duration <- c(2, 3, 4, 5)

# Read data ----
df_temp_data_nola <- read_fst(here(path_processed_data, "2.3_nola_wbgt_zip_code.fst"), as.data.table = TRUE)
head(df_temp_data_nola)
sum(is.na(df_temp_data_nola$wbgt_max))
# min(df_temp_data_nola$date)
# max(df_temp_data_nola$date)

length(unique(df_temp_data_nola$Zip)) # 26 zip codes


# Create basic date variables ---------
df_temp_data_nola <- df_temp_data_nola[, ':=' (
                                        weekday = lubridate::wday(date, label = TRUE),
                                        year = lubridate::year(date),
                                        month = lubridate::month(date),
                                        day_of_year = lubridate::yday(date))]

colnames(df_temp_data_nola)
# Create temperature cutoffs using long-term data --------

## Cut offs using Zip code and day of year
setDT(df_temp_data_nola)
for (val in vec_cutoffs_perc) {
        ## Create new variable using ZIP and DOY
        new_var_zip_doy <- paste0("cutoff_", "zip_doy_",  val*100)
        df_temp_data_nola[, (new_var_zip_doy) := quantile(get(heat_var), probs = val, na.rm = TRUE), by = .(Zip, day_of_year)]
        ## Create new variable using ZIP only
        new_var_zip <- paste0("cutoff_", "zip_only_", val*100)
        df_temp_data_nola[, (new_var_zip) := quantile(get(heat_var), probs = val, na.rm = TRUE), by = .(Zip)]
}
colnames(df_temp_data_nola)
print("step-1-complete")
print(Sys.time())

# Filter to cases between 2011 and 2023 --------
df_temp_data_nola <- df_temp_data_nola[base::`<=`(df_temp_data_nola$date, as.Date("2023-12-31")), ]
df_temp_data_nola <- df_temp_data_nola[base::`>=`(df_temp_data_nola$date, as.Date("2011-01-01")), ]
min(df_temp_data_nola$date)
max(df_temp_data_nola$date)

# Create vectors of cutoff variables and values and for duration ----
vec_varlist_cutoffs_perc <- colnames(df_temp_data_nola)[grepl("cutoff", colnames(df_temp_data_nola))]
head(df_temp_data_nola)
# Create extreme heat days ----
## For n-tiles
for (var in vec_varlist_cutoffs_perc) {
  # Create new variable name by replacing "cutoff" with "hotday"
  new_var <- gsub("cutoff", "rel_hd", var)
  
  # Debug: Print variable names
  print(paste("Processing:", var, "->", new_var))
  
  # Check if the variable exists
  if (var %in% names(df_temp_data_nola)) {
    # Create the new variable
    df_temp_data_nola[[new_var]] <- ifelse(df_temp_data_nola[[heat_var]] >= df_temp_data_nola[[var]], 1, 0)
  } else {
    warning(paste("Variable", var, "not found in df_temp_data_nola"))
  }
}

colnames(df_temp_data_nola)

## For absolute values
for (val in vec_cutoffs_abs) {
  # Create new variable name by replacing "cutoff" with "hotday"
  new_var <- paste0("abs_hd_", val)
  
  # Create the new variable
  df_temp_data_nola[[new_var]] <- ifelse(df_temp_data_nola[[heat_var]] >= val, 1, 0)
}
colnames(df_temp_data_nola)


# Create variables for consecutive days ----

## Identify all variables that start with "hotday"
vec_hotday_vars <- colnames(df_temp_data_nola)[grepl("rel_hd|abs_hd", colnames(df_temp_data_nola))]

## Create the variables in a loop
setDT(df_temp_data_nola)

# Create the variables in a loop
for (var in vec_hotday_vars) {
  # Create new variable name by appending "consec" to the variable name
  new_var <- paste0("consec_", var)

  # Print debugging information
  cat("Processing:", var, "->", new_var, "\n")
  
  # Create the new variable
  df_temp_data_nola[, (new_var) := fifelse(get(var) == 1, seq_len(.N), 0L), by = rleid(get(var))]
  
  # Confirm creation
  if (new_var %in% names(df_temp_data_nola)) {
    cat("Successfully created:", new_var, "\n")
  } else {
    cat("Failed to create:", new_var, "\n")
  }
}

colnames(df_temp_data_nola)

# Create heatwave vars ----

## Identify all variables that start with "consec"
vec_consec_vars <- colnames(df_temp_data_nola)[grepl("consec", colnames(df_temp_data_nola))]

## Create the variables in a loop
for (var in vec_consec_vars) {
        for (duration in vec_duration) {
                # Create new variable name by dropping "consec_" and replacing "hd" with "hw"                
                new_var <- gsub("consec_", "", var)
                new_var <- gsub("hd", "hw", new_var)
                new_var <- paste0(new_var, "_", duration, "d")
                # Create the new variable
                df_temp_data_nola[[new_var]] <- ifelse(df_temp_data_nola[[var]] >= duration, 1, 0)
        }
}
colnames(df_temp_data_nola)
print("heatwave vars created")
print(Sys.time())

# Check dataset ----
# View(df_temp_data_nola |> filter(Zip == "70125"))
## Generate a summary of all hotday variables 
df_temp_data_nola |> select(starts_with("abs_hd")) |> summary()
## Generate a summary of all heatwave variables 
df_temp_data_nola |> select(starts_with("rel_hw")) |> summary()

# Save Work
write_fst(df_temp_data_nola, path = here(path_processed_data, "2.4-clim-vars-wbgt.fst"))

colnames(df_temp_data_nola)
