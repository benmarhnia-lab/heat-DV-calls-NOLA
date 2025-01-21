#' This script merges the filled zip data with the main data. 
#' The filled data was provided by Edwin and Namratha.

# load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)

# set paths ----
source("paths-mac.R")

# read data
## read raw-dv data
df_nopd_dv_cases_all <- read_fst(here(path_project, "processed-data", "1.1b-nopd-calls-raw-dv-only.fst"), as.data.table = TRUE)
nrow(df_nopd_dv_cases_all) # 167,042 cases

### subset of data where zip code is missing
df_missing_zip <- df_nopd_dv_cases_all |> filter(is.na(Zip) | Zip == "None" | Zip == "") 

### create a dataframe for all complete cases ----
df_complete_zip <- df_nopd_dv_cases_all[uid %in% df_missing_zip$uid == FALSE]

#### quick check -----
nrow(df_complete_zip)
nrow(df_nopd_dv_cases_all) - nrow(df_missing_zip) 

## read filled zip data ----
df_filled_zip_edwin_namratha <- read.csv(here(path_project, "raw-data", "nopd-missing-zips-filled-by-Edwin-Namratha.csv"), stringsAsFactors = FALSE)
nrow(df_filled_zip_edwin_namratha)
df_filled_zip_edwin_namratha <- df_filled_zip_edwin_namratha |> select(uid, Zip)
length(unique(df_filled_zip_edwin_namratha$uid))

# perform the merge ----
## first complete the zip column in the filled data ----
df_missing_zip_new <- df_missing_zip |> select(-Zip)
df_missing_zip_new <- df_missing_zip_new |> left_join(df_filled_zip_edwin_namratha, by = "uid")
colnames(df_missing_zip_new)

sum(is.na(df_missing_zip_new$Zip))

### drop cases with missing Zip codes
df_missing_zip_new <- df_missing_zip_new |> filter(!is.na(Zip))

## combine the two datasets ----
df_nopd_dv_cases_full <- rbind(df_complete_zip, df_missing_zip_new)

### quick checks ----
nrow(df_nopd_dv_cases_full)
nrow(df_nopd_dv_cases_all)
nrow(df_complete_zip)
nrow(df_missing_zip_new)

# filter to retain cases before 2021 ----
max(df_nopd_dv_cases_full$date)
df_nopd_dv_cases_full <- df_nopd_dv_cases_full |> filter(date < "2022-01-01") |> filter(year != "23")

## save the data ----
df_nopd_dv_cases_full |> write_fst(here(path_project, "processed-data", "1.3-nopd-calls-raw-dv-only-completed.fst"))
# df_nopd_dv_cases_full <- read_fst(here(path_project, "processed-data", "1.3-nopd-calls-raw-dv-only-completed.fst"))
# head(df_nopd_dv_cases_full |> filter(year == "23"))
