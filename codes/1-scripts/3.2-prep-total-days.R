# Load Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, here, survival)
pacman::p_load(doParallel)

# set paths ----
source("paths-mac.R")

# Read Data ----
## Climate data 
df_climate_utci <- read_fst(here(path_project, "processed-data", "2.3-clim-vars-utci.fst"), as.data.table = TRUE)
nrow(df_climate_utci)
glimpse(df_climate_utci)

## NOPD - DV calls data 
df_dv_agg <- read_fst(here(path_project, "processed-data", "1.4-DV-cases-agg.fst"), as.data.table = TRUE)
nrow(df_dv_agg)
glimpse(df_dv_agg)

# Merge NOPD data with climate data ----
df_nopd_utci_merged <- df_dv_agg |> left_join(df_climate_utci,
                        by = c("Zip", "case_date" = "date"))
nrow(df_nopd_utci_merged)
head(df_nopd_utci_merged)

## List all variables that start with "hd" or "hw"
varlist_exp_abs <- colnames(df_nopd_utci_merged)[grepl("^abs", colnames(df_nopd_utci_merged))]
varlist_exp_rel <- colnames(df_nopd_utci_merged)[grepl("^rel", colnames(df_nopd_utci_merged))]
varlist_exp_all <- c(varlist_exp_abs, varlist_exp_rel)

# Calculate sums for each exposure variable
# Calculate means of DV_count for each exposure variable when variable == 1
df_exp_means <- data.frame(
  variable = varlist_exp_all,
  num_days = sapply(df_nopd_utci_merged[, ..varlist_exp_all], sum, na.rm = TRUE),
  mean_dv = sapply(varlist_exp_all, function(var) {
    mean(df_nopd_utci_merged$DV_count[df_nopd_utci_merged[[var]] == 1], na.rm = TRUE)
  })
) |>
mutate(total_cases = num_days * mean_dv) 


head(df_exp_means)

# Check ----
sum(df_nopd_utci_merged$abs_hd_28)
df_nopd_utci_merged |> filter(abs_hd_28 == 1) |> select(DV_count) |> summary()

# Save the dataframe
df_exp_means |> write_fst(here(path_project, "processed-data", "3.2-prep-total-cases.fst"))