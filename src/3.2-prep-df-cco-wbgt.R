# Load packages ---- 
rm(list = ls())
library(tidyverse)
library(fst)
library(data.table)
library(janitor)
library(here)

# Read data ----
path_processed <- here("data", "processed-data")
## Climate data ----- 
df_climate_wbgt <- read_fst(here(path_processed, "3.1-lt-clim-vars-wbgt.fst"), as.data.table = TRUE)
df_climate_tmax <- read_fst(here(path_processed, "3.2-lt-clim-vars-tmax.fst"), as.data.table = TRUE)

## NOPD - DV calls data -----
df_dv_agg <- read_fst(here(path_processed, "1.4-DV-cases-agg.fst"), as.data.table = TRUE)

# Merge NOPD data with climate data ----

## WBGT -----
head(df_dv_agg)
head(df_climate_wbgt)
df_nopd_wbgt_merged <- df_dv_agg |> left_join(df_climate_wbgt, 
                        by = c("Zip", "year", "month", "weekday"))

# View((df_nopd_wbgt_merged[1:200,]))

## Tmax -----
head(df_dv_agg)
head(df_climate_tmax)
df_nopd_tmax_merged <- df_dv_agg |> left_join(df_climate_tmax, 
                        by = c("Zip", "year", "month", "weekday"))

# View((df_nopd_tmax_merged[1:200,]))

## Create a variable to identify DV cases -----
## WBGT
df_nopd_wbgt_merged <- df_nopd_wbgt_merged |> 
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date.y, "%Y-%m-%d"), 1, 0)
  )
sum(df_nopd_wbgt_merged$dv_case)
# View((df_nopd_wbgt_merged[1:200,]))

## Tmax
df_nopd_tmax_merged <- df_nopd_tmax_merged |> 
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date.y, "%Y-%m-%d"), 1, 0)
  )

# Inspect missing temperature cases ----
# df_test <- df_nopd_wbgt_merged[is.na(wbgt_max)]
# unique(df_test$Zip)
# 70118 and 70131 zip codes are missing. These were missing in script 1.4 as well.

# Drop cases with Zip codes 70118 and 70131 ----
# df_nopd_wbgt_merged <- df_nopd_wbgt_merged |> filter(!Zip %in% c("70118", "70131"))
# sum(is.na(df_nopd_wbgt_merged$tmax))

# Save work
write_fst(df_nopd_wbgt_merged, here(path_processed, "4.1-a-cco-data-wbgt.fst"))
write_fst(df_nopd_tmax_merged, here(path_processed, "4.1-b-cco-data-tmax.fst"))

