# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey (arnabxdey@gmail.com)
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script generates the attributable fraction and attributable numbers for the CCO analysis
# @date: Feb 4, 2025

# load libraries ----
rm(list = ls())
pacman::p_load(dplyr, openxlsx, here, sandwich, survival)

# source function to generate confidence intervals for attributable fraction and attributable numbers ----
source(here("R", "functions", "func-gen-MC-CIs.R"))

# load models ----
model_outputs <- readRDS(here("Data", "2.1_models_cco_utci.rds"))

# load the dataset with the total days exposed ----
df_total_cases <- readRDS(here("Data", "1.3_days_exposed.rds"))

# generate attributable fractions and attributable numbers and CIs ----
set.seed(0112358)
outputs <- generate_af_an_ci(model_outputs, df_total_cases, 1000, 0.95)

# save the outputs ----
outputs |> write.csv(here("Data", "2.3-outputs-attributable-fraction.csv"))


