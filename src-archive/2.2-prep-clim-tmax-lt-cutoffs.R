# Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)
pacman::p_load(parallel, future, furrr, doParallel, foreach, future.apply)
# devtools::install_github("axdey/climExposuR")
library(climExposuR)
source("paths-mac.R")

# Constants ----
path_processed_data <- here(path_project, "processed-data")

# source(here("src", "8.4-function-to-est-perc-cutoff-rolling.R"))

# Read data ----
df_temp_data_nola <- read_fst(here(path_processed_data, "2.1_nola_tmax_zip_code.fst"), as.data.table = TRUE)
# df_temp_data_nola <- df_temp_data_nola[Zip < 70006]
# head(df_temp_data_nola)
# min(df_temp_data_nola$date)
# max(df_temp_data_nola$date)

length(unique(df_temp_data_nola$Zip)) # 26 zip codes

print("loading complete")
print(Sys.time())


# Create LT percentile cutoffs using the rolling method: 85 ----
df_cutoffs_rolling_85 <- flexi_percentile_cutoffs(DT = df_temp_data_nola, var_col = "tmax", 
                                ntile = 0.85, 
                                perc_type = "rolling", 
                                num_days = 3, 
                                psu_col = "Zip", 
                                num_cores_leave = 1)

setnames(df_cutoffs_rolling_85, "PSU", "Zip")
write_fst(df_cutoffs_rolling_85, here(path_processed_data, "2.2a_nola_tmax_zip_code_cutoffs_rolling_85.fst"))
rm(df_cutoffs_rolling_85)
print("rolling-85 complete")
print(Sys.time())   
# Create LT percentile cutoffs using the rolling method: 90 ----
df_cutoffs_rolling_90 <- flexi_percentile_cutoffs(DT = df_temp_data_nola, var_col = "tmax", 
                                ntile = 0.90, 
                                perc_type = "rolling", 
                                num_days = 3, 
                                psu_col = "Zip", 
                                num_cores_leave = 1)

setnames(df_cutoffs_rolling_90, "PSU", "Zip")
write_fst(df_cutoffs_rolling_90, here(path_processed_data, "2.2b_nola_tmax_zip_code_cutoffs_rolling_90.fst"))
rm(df_cutoffs_rolling_90)
print("rolling-90 complete")
print(Sys.time())

# Create LT percentile cutoffs using the rolling method: 95 ----
df_cutoffs_rolling_95 <- flexi_percentile_cutoffs(DT = df_temp_data_nola, var_col = "tmax", 
                                ntile = 0.95, 
                                perc_type = "rolling", 
                                num_days = 3, 
                                psu_col = "Zip", 
                                num_cores_leave = 1) 

setnames(df_cutoffs_rolling_95, "PSU", "Zip")
write_fst(df_cutoffs_rolling_95, here(path_processed_data, "2.2c_nola_tmax_zip_code_cutoffs_rolling_95.fst"))
rm(df_cutoffs_rolling_95)

print("rolling-95 complete")
print(Sys.time())



# Merge the three datasets ----

## Read all datasets ----
# df_nola_zip_tmax <- read_fst(here(path_processed_data, "2.1_nola_tmax_zip_code.fst"), as.data.table = TRUE)
df_cutoffs_rolling_85 <- read_fst(here(path_processed_data, "2.2a_nola_tmax_zip_code_cutoffs_rolling_85.fst"), as.data.table = TRUE)
df_cutoffs_rolling_90 <- read_fst(here(path_processed_data, "2.2b_nola_tmax_zip_code_cutoffs_rolling_90.fst"), as.data.table = TRUE)
df_cutoffs_rolling_95 <- read_fst(here(path_processed_data, "2.2c_nola_tmax_zip_code_cutoffs_rolling_95.fst"), as.data.table = TRUE)

## Merge the three datasets ----
df_lt_cutoff_temp <- merge(df_cutoffs_rolling_85, df_cutoffs_rolling_90, by = c("date", "Zip"), all = TRUE)
df_lt_cutoff_all <- merge(df_lt_cutoff_temp, df_cutoffs_rolling_95, by = c("date", "Zip"), all = TRUE)
View(df_lt_cutoff_all)
rm(df_lt_cutoff_temp)

## Merge with the original dataset ----
df_merged <- merge(df_temp_data_nola, df_lt_cutoff_all, by = c("date", "Zip"), all = TRUE)

# Save the final dataset ----
write.fst(df_merged, here(path_processed_data, "2.2_nola_tmax_zip_cutoffs_added.fst"))
print("final complete")
print(Sys.time())


