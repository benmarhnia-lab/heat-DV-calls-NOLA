# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script runs the models for the CCO analysis
# @date: Feb 4, 2025

# load Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, here, survival, doParallel)

# load data ----
df_cco_tmax <- readRDS(here("Data", "1.4-DV_merged_UTCI_cco.rds"))

# List of exposure variables ----
## List all variables that start with "hd" or "hw"
varlist_exp_abs <- colnames(df_cco_tmax)[grepl("^abs", colnames(df_cco_tmax))]
varlist_exp_rel <- colnames(df_cco_tmax)[grepl("^rel", colnames(df_cco_tmax))]
varlist_exp_all <- c(varlist_exp_abs, varlist_exp_rel)

# run models ----
## register parallel backend
no_cores <- detectCores() - 2
registerDoParallel(cores = no_cores)

## helper functions to construct and run models
run_model <- function(exposure, data, method) {
  formula_string <- paste("dv_case", "~", exposure, "+", 
                          "+ strata(ID_grp)")
  model <- survival::clogit(as.formula(formula_string), weights = DV_count, data = data, method = method)
  return(model)
}

## initialize an empty list to store all model outputs
all_model_outputs <- list()

## run models in parallel
models_all <- foreach(exposure = varlist_exp_all, .packages = c("survival", "broom.mixed")) %dopar% {
  run_model(exposure, df_cco_tmax, "approximate")
}

## name the list elements
names(models_all) <- varlist_exp_all

## extract model outputs
all_model_outputs <- models_all

# save the list as an RDS object ----
saveRDS(all_model_outputs, here("Data", "2.1_models_cco_utci.rds"))
