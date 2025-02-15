# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey (arnabxdey@gmail.com)
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script creates long-term cutoffs for the 90th percentile of UTCI for each zip code
# @date: Feb 4, 2025

# load libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, here, parallel, doParallel, tictoc)

# load data ----
df_temp_data_nola <- readRDS(here("Data", "0.1_UTCI_NOLA_zip.rds"))

# source functions ----
source(here("R", "functions", "func-flexi-cutoffs.R"))

# create long-term cutoffs for 90th percentile ----
tic()
df_cutoffs_rolling_90 <- flexi_percentile_cutoffs(
                                DT = df_temp_data_nola, 
                                var_col = "utci_mean", 
                                ntile = 0.90, 
                                perc_type = "rolling", 
                                num_days = 3, 
                                psu_col = "Zip", 
                                num_cores_leave = 2)
                                
setnames(df_cutoffs_rolling_90, "PSU", "Zip")

# merge with the original dataset ----
df_merged <- merge(df_temp_data_nola, df_cutoffs_rolling_90, by = c("date", "Zip"), all = TRUE)

# save the dataset ----
df_merged |> saveRDS(here("Data", "1.1_UTCI_NOLA_zip_cutoffs.rds"))
