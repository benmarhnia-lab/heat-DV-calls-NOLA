# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey 
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script calculates the total number of cases for each exposure variable
# @date: Feb 4, 2025

# Load Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, here)

# Read Data ----
## Climate data 
df_climate_utci <- readRDS(here("Data", "1.2_UTCI_NOLA_zip_clim_vars.rds"))

## NOPD - DV calls data 
df_dv_agg <- readRDS(here("Data", "0.2_DV_cases_agg.rds"))

# Merge NOPD data with climate data ----
df_nopd_utci_merged <- df_dv_agg |> left_join(df_climate_utci,
                        by = c("Zip", "case_date" = "date"))

# List all variables that start with "hd" or "hw" ----
varlist_exp_abs <- colnames(df_nopd_utci_merged)[grepl("^abs", colnames(df_nopd_utci_merged))]
varlist_exp_rel <- colnames(df_nopd_utci_merged)[grepl("^rel", colnames(df_nopd_utci_merged))]
varlist_exp_all <- c(varlist_exp_abs, varlist_exp_rel)

# Calculate number of days and mean DV count for each exposure variable ----
df_exp_means <- data.frame(
  variable = varlist_exp_all,
  num_days = sapply(df_nopd_utci_merged[, ..varlist_exp_all], sum, na.rm = TRUE),
  mean_dv = sapply(varlist_exp_all, function(var) {
    mean(df_nopd_utci_merged$DV_count[df_nopd_utci_merged[[var]] == 1], na.rm = TRUE)
  })) |>
  mutate(total_cases = num_days * mean_dv) 

# save data ----
df_exp_means |> saveRDS(here("Data", "1.3_days_exposed.rds"))