#' This script aggregates the data by zip code and day. 
#' It also creates a few variables for year, month, weekday, and case_date. 
#' The final dataset is saved as 1.4-DV-cases-agg.fst.

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
source("paths-mac.R")

# Read NOPD-DV cases ---- 
df_nopd_dv_cases <- read_fst(here(path_project, "processed-data", "1.3-nopd-calls-raw-dv-only-completed.fst"), 
    as.data.table = TRUE)
# nrow(df_nopd_dv_cases)
# colnames(df_nopd_dv_cases)
# tabyl(df_nopd_dv_cases$Zip)

# Create a variables for date ---- 
df_dv_cases_valid <- df_nopd_dv_cases[, ':=' (
                      date = as.Date(TimeCreate, format = "%m/%d/%Y"))]

# Aggregate by Zip-code Day ----
df_dv_cases_agg <- df_dv_cases_valid[, .(DV_count = sum(DV_related)), 
                                      by = c("Zip", "date")]

# Create ID_grp variable ----
df_dv_cases_agg$ID_grp <- seq.int(nrow(df_dv_cases_agg))

# Create a variables for year, month and weekday ---- 
df_dv_cases_agg <- df_dv_cases_agg[, ':=' (
                      year = lubridate::year(date),
                      month = lubridate::month(date),
                      weekday = lubridate::wday(date, label = TRUE),
                      case_date = date)][, date := NULL]

nrow(df_dv_cases_agg) # 60083
length(unique(df_dv_cases_agg$Zip)) # 29
# View(head(df_dv_cases_agg))

# Drop Zip codes with less than 50 cases ---
df_dv_cases_agg <- df_dv_cases_agg |> 
  group_by(Zip) |>
  filter(n() >= 50) |>
  ungroup()
nrow(df_dv_cases_agg) # 60028

# Save file ----
df_dv_cases_agg |> write_fst(here(path_project, "processed-data", "1.4-DV-cases-agg.fst"))
# df_dv_cases_agg <- read_fst(here(path_project, "processed-data", "1.4-DV-cases-agg.fst"))
# length(unique(df_dv_cases_agg$Zip)) # 17
