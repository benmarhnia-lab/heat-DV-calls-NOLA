# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey (arnabxdey@gmail.com)
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script creates exposure variables for each zip code
# @date: Feb 4, 2025

# load libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, here)

# constants ----
vec_duration <- c(3, 5)

# load data ----
df_temp_data_nola <- readRDS(here("Data", "1.1_UTCI_NOLA_zip_cutoffs.rds"))

# create basic date variables ----
df_temp_data_nola <- df_temp_data_nola[, ':=' (
                                        weekday = lubridate::wday(date, label = TRUE),
                                        year = lubridate::year(date),
                                        month = lubridate::month(date),
                                        day_of_year = lubridate::yday(date))]


# create exposure variables for hotday ----
## for percentile 90 
df_temp_data_nola$rel_hd_rolling_90 <- ifelse(df_temp_data_nola$utci_mean >= df_temp_data_nola$cutoff_rolling_90, 1, 0)

## for absolute 30
df_temp_data_nola$abs_hd_rolling_30 <- ifelse(df_temp_data_nola$utci_mean >= 30, 1, 0)

# Create variables for consecutive days ----
## Sort the data by date and Zip
setorder(df_temp_data_nola, Zip, date)

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
  df_temp_data_nola[, (new_var) := fifelse(get(var) == 1, seq_len(.N), 0L), by = .(Zip, rleid(get(var)))]
  
  # Confirm creation
  if (new_var %in% names(df_temp_data_nola)) {
    cat("Successfully created:", new_var, "\n")
  } else {
    cat("Failed to create:", new_var, "\n")
  }
}

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

# save data ----
df_temp_data_nola |> saveRDS(here("Data", "1.2_UTCI_NOLA_zip_clim_vars.rds"))
