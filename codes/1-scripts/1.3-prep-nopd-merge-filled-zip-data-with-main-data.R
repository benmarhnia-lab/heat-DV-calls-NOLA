#' This script merges the filled zip data with the main data. 
#' The filled data was provided by Edwin and Namratha.

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
source("paths-mac.R")

# Read data
## Read raw-dv data
path_processed_data <- here(path_project, "processed-data")
df_nopd_dv_cases_all <- read_fst(here(path_processed_data, "1.1b-nopd-calls-raw-dv-only.fst"), as.data.table = TRUE)
nrow(df_nopd_dv_cases_all) # 167,042 cases

### Subset of data where zip code is missing
df_missing_zip <- df_nopd_dv_cases_all |> filter(is.na(Zip) | Zip == "None" | Zip == "") 

### Create a dataframe for all complete cases ----
df_complete_zip <- df_nopd_dv_cases_all[uid %in% df_missing_zip$uid == FALSE]

#### Quick check -----
nrow(df_complete_zip)
nrow(df_nopd_dv_cases_all) - nrow(df_missing_zip) 

## Read filled zip data ----
df_filled_zip_edwin_namratha <- read.csv(here(path_project, "raw-data", "nopd-missing-zips-filled-by-Edwin-Namratha.csv"), stringsAsFactors = FALSE)
nrow(df_filled_zip_edwin_namratha)
df_filled_zip_edwin_namratha <- df_filled_zip_edwin_namratha |> select(uid, Zip)
length(unique(df_filled_zip_edwin_namratha$uid))

# Perform the merge ----

## First complete the zip column in the filled data ----
df_missing_zip_new <- df_missing_zip |> select(-Zip)
df_missing_zip_new <- df_missing_zip_new |> left_join(df_filled_zip_edwin_namratha, by = "uid")
colnames(df_missing_zip_new)

sum(is.na(df_missing_zip_new$Zip))

### Drop cases with missing Zip codes
df_missing_zip_new <- df_missing_zip_new |> filter(!is.na(Zip))

## Combine the two datasets ----
df_nopd_dv_cases_full <- rbind(df_complete_zip, df_missing_zip_new)

### Quick checks ----
nrow(df_nopd_dv_cases_full)
nrow(df_nopd_dv_cases_all)
nrow(df_complete_zip)
nrow(df_missing_zip_new)

## Save the data ----
write_fst(df_nopd_dv_cases_full, 
    here(path_processed_data, "1.3-nopd-calls-raw-dv-only-completed.fst"))