# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script generates the attributable fraction and attributable numbers for the CCO analysis
# @date: Feb 4, 2025

# load libraries ----
rm(list = ls())
pacman::p_load(dplyr, openxlsx, here, sandwich, survival)

# source function to generate confidence intervals for attributable fraction and attributable numbers ----
source(here("R", "functions", "func-gen-MC-CIs-AF-AN.R"))

# load models ----
model_outputs <- readRDS(here("Data", "2.1_models_cco_utci.rds"))

# load the dataset with the total days exposed ----
df_total_cases <- readRDS(here("Data", "1.3_days_exposed.rds"))

# generate attributable fractions and attributable numbers and CIs ----
set.seed(0112358)
outputs <- generate_af_an_ci(model_outputs, df_total_cases, 1000, 0.95)

# arrange the exposure variable
sorted_df <- data.frame(
  exposure = c(
    "abs_hd_28", "abs_hw_28_2d", "abs_hw_28_3d", "abs_hw_28_4d", "abs_hw_28_5d",
    "abs_hd_30", "abs_hw_30_2d", "abs_hw_30_3d", "abs_hw_30_4d", "abs_hw_30_5d",
    "abs_hd_32", "abs_hw_32_2d", "abs_hw_32_3d", "abs_hw_32_4d", "abs_hw_32_5d",
    "rel_hd_rolling_85", "rel_hw_rolling_85_2d", "rel_hw_rolling_85_3d", "rel_hw_rolling_85_4d", "rel_hw_rolling_85_5d",
    "rel_hd_rolling_90", "rel_hw_rolling_90_2d", "rel_hw_rolling_90_3d", "rel_hw_rolling_90_4d", "rel_hw_rolling_90_5d",
    "rel_hd_rolling_95", "rel_hw_rolling_95_2d", "rel_hw_rolling_95_3d", "rel_hw_rolling_95_4d", "rel_hw_rolling_95_5d"
  )
)
outputs <- sorted_df |> left_join(outputs, by = "exposure")

# save the outputs ----
outputs |> write.csv(here("Data", "2.3-outputs-attributable-fraction.csv"))


