# Load packages ----
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed)

# Read NOPD-DV cases ---- 
rm(list = ls())
df_nopd_dv_cases <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/heat-and-nopd-dv-calls/1.2-nopd-calls-raw-dv-only-completed.fst",
                              as.data.table = TRUE)
nrow(df_nopd_dv_cases)
colnames(df_nopd_dv_cases)

tabyl(df_nopd_dv_cases$Zip)

# Create a variables for date ---- 
df_dv_cases_valid <- df_dv_cases_valid[, ':=' (
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
                      case_date = date)]

# Save file ----
write_fst(df_dv_cases_agg, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.3-DV-cases-agg.fst")