# load libraries ----
rm(list = ls())
pacman::p_load(dplyr, janitor, data.table, fst, openxlsx, here, sandwich, survival)

# set paths ----
source(here("paths-mac.R"))

# source function to generate confidence intervals for attributable fraction
source(here("codes", "2-helper-functions", "function-to-gen-MC-CIs.R"))

# load models ----
model_outputs <- readRDS(here(path_project, "processed-data", "4.1-models-cco-utci_21.rds"))

# load the dataset with the total number of cases 
df_total_cases <- read_fst(here(path_project, "processed-data", "3.2-prep-total-cases.fst"))

# generate attributable fractions and attributable numbers ----
outputs <- generate_af_an_ci(model_outputs, df_total_cases, 1000, 0.95)

# save the outputs ----
outputs |> write.csv(here(path_project, "outputs", "5.3-outputs-attributable-fraction.csv"))


