# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey (arnabxdey@gmail.com)
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script prepares the data for the case crossover analysis
# @date: Feb 4, 2025

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, here)

# load data ----
## climate data 
df_climate_utci <- readRDS(here("Data", "1.2_UTCI_NOLA_zip_clim_vars.rds"))

## NOPD - DV calls data -----
df_dv_agg <- readRDS(here("Data", "0.2_DV_cases_agg.rds"))

# merge NOPD data with climate data ----
df_nopd_utci_merged <- df_dv_agg |> left_join(df_climate_utci,
                        by = c("Zip", "year", "month", "weekday"))

# create a variable to identify DV cases -----
df_nopd_utci_merged <- df_nopd_utci_merged |>
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date, "%Y-%m-%d"), 1, 0)
  )

# save the data ----
df_nopd_utci_merged |> saveRDS(here("Data", "1.4-DV_merged_UTCI_cco.rds"))
