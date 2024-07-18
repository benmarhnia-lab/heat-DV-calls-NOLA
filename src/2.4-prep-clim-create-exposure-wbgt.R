# Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)

# Read data ----
path_processed_data <- here("data", "processed-data")
df_temp_data_nola <- read_fst(here(path_processed_data, "2.1_nola_wbgt_zip_code.fst"), as.data.table = TRUE)
head(df_temp_data_nola)
min(df_temp_data_nola$date)

length(unique(df_temp_data_nola$Zip)) # 17 zip codes

# Drop the Attribute column
df_temp_data_nola <- df_temp_data_nola[, -c("Attribute")]

# Create basic date variables
df_temp_data_nola <- df_temp_data_nola[, ':=' (
                                        weekday = lubridate::wday(date, label = TRUE),
                                        year = lubridate::year(date),
                                        month = lubridate::month(date),
                                        day_of_year = lubridate::yday(date))]


# Step-1: Create temperature variables that need long-term data
df_temp_data_nola <- df_temp_data_nola[
    ## 90th/95th percentile variables by week by Zip
    ### Tmax-Wb
    , cutoff_tmax_wb_90 := quantile(wbgt_max, probs = 0.90, na.rm = T), by = c("Zip", "day_of_year")][
    , cutoff_tmax_wb_95 := quantile(wbgt_max, probs = 0.95, na.rm = T), by = c("Zip", "day_of_year")][
    , cutoff_tmax_wb_97 := quantile(wbgt_max, probs = 0.97, na.rm = T), by = c("Zip", "day_of_year")]
    
print("step-1-complete")
print(Sys.time())


## Filter to cases between 2011 and 2023
df_temp_data_nola <- df_temp_data_nola[base::`<=`(df_temp_data_nola$date, as.Date("2023-12-31")), ]
df_temp_data_nola <- df_temp_data_nola[base::`>=`(df_temp_data_nola$date, as.Date("2011-01-01")), ]
min(df_temp_data_nola$date)
max(df_temp_data_nola$date)

# Step-2: Create extreme heat days ----
df_temp_data_nola <- df_temp_data_nola[
        ## Based on n-tiles
        ### Wetbulb
        , hotday_90_wb := ifelse(wbgt_max >= cutoff_tmax_wb_90, 1, 0)][
        , hotday_95_wb := ifelse(wbgt_max >= cutoff_tmax_wb_95, 1, 0)][
        , hotday_97_wb := ifelse(wbgt_max >= cutoff_tmax_wb_97, 1, 0)][
        ## Based on absoulte values
        ### Wetbulb
        , hotday_30_wb := ifelse(wbgt_max >= 30, 1, 0)][
        , hotday_31_wb := ifelse(wbgt_max >= 31, 1, 0)][
        , hotday_32_wb := ifelse(wbgt_max >= 32, 1, 0)]

print("extreme heat days created")


# Step-4: Create Heatwave vars for 2,3, and 5 days -----
## First create consecutive days of extreme temperature ----
df_temp_data_nola <- df_temp_data_nola[
        ## Based on n-tiles
        ### Wetbulb
        , consec_days_90_wb := ifelse(hotday_90_wb == 1, 1:.N, 0L), by = rleid(hotday_90_wb)][
        , consec_days_95_wb := ifelse(hotday_95_wb == 1, 1:.N, 0L), by = rleid(hotday_95_wb)][
        , consec_days_97_wb := ifelse(hotday_97_wb == 1, 1:.N, 0L), by = rleid(hotday_97_wb)][
        ## Based on absoulte values
        ### Wetbulb
        , consec_days_30_wb := ifelse(hotday_30_wb == 1, 1:.N, 0L), by = rleid(hotday_30_wb)][
        , consec_days_31_wb := ifelse(hotday_31_wb == 1, 1:.N, 0L), by = rleid(hotday_31_wb)][
        , consec_days_32_wb := ifelse(hotday_32_wb == 1, 1:.N, 0L), by = rleid(hotday_32_wb)]

## Create heatwave vars ----
df_temp_data_nola <- df_temp_data_nola[
        ## Based on n-tiles
        ### Wetbulb
        , hw_90_wb_2d := ifelse(consec_days_90_wb >= 2, 1, 0)][
        , hw_90_wb_3d := ifelse(consec_days_90_wb >= 3, 1, 0)][
        , hw_90_wb_5d := ifelse(consec_days_90_wb >= 5, 1, 0)][
        , hw_95_wb_2d := ifelse(consec_days_95_wb >= 2, 1, 0)][
        , hw_95_wb_3d := ifelse(consec_days_95_wb >= 3, 1, 0)][
        , hw_95_wb_5d := ifelse(consec_days_95_wb >= 5, 1, 0)][
        , hw_97_wb_2d := ifelse(consec_days_97_wb >= 2, 1, 0)][
        , hw_97_wb_3d := ifelse(consec_days_97_wb >= 3, 1, 0)][
        , hw_97_wb_5d := ifelse(consec_days_97_wb >= 5, 1, 0)][
        ## Based on absolute values
        ## Wetbulb
        , hw_30_wb_2d := ifelse(consec_days_30_wb >= 2, 1, 0)][
        , hw_30_wb_3d := ifelse(consec_days_30_wb >= 3, 1, 0)][
        , hw_30_wb_5d := ifelse(consec_days_30_wb >= 5, 1, 0)][
        , hw_31_wb_2d := ifelse(consec_days_31_wb >= 2, 1, 0)][
        , hw_31_wb_3d := ifelse(consec_days_31_wb >= 3, 1, 0)][
        , hw_31_wb_5d := ifelse(consec_days_31_wb >= 5, 1, 0)][
        , hw_32_wb_2d := ifelse(consec_days_32_wb >= 2, 1, 0)][
        , hw_32_wb_3d := ifelse(consec_days_32_wb >= 3, 1, 0)][
        , hw_32_wb_5d := ifelse(consec_days_32_wb >= 5, 1, 0)]

print("heatwave vars created")
print(Sys.time())

# Save Work
write_fst(df_temp_data_nola, path = here(path_processed_data, "3.1-lt-clim-vars-wbgt.fst"))


