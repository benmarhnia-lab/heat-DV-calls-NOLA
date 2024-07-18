# Load Libraries ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here, survival)
pacman::p_load(doParallel)

# Constants ----
path_processed <- here("data", "processed-data")

# Read Data ----
df_cco_tmax <- read_fst(here(path_processed, "3.3-cco-data-heat-index.fst"), as.data.table = TRUE)


# List of exposure variables ----
colnames(df_cco_tmax)
## List all variables that start with "hd" or "hw"
varlist_exp_abs <- colnames(df_cco_tmax)[grepl("^abs", colnames(df_cco_tmax))]
varlist_exp_rel <- colnames(df_cco_tmax)[grepl("^rel", colnames(df_cco_tmax))]
varlist_exp_all <- c(varlist_exp_abs, varlist_exp_rel)

## Register parallel backend
no_cores <- detectCores() - 1
registerDoParallel(cores = no_cores)
## Use foreach to iterate over exposures in parallel
print(Sys.time())

# Helper functions to construct and run models
run_model <- function(exposure, data, method) {
  formula_string <- paste("dv_case", "~", exposure, "+", 
                          "+ strata(ID_grp)")
  model <- survival::clogit(as.formula(formula_string), weights = DV_count, data = data, method = method)
  return(model)
}

# Initialize an empty list to store all model outputs
all_model_outputs <- list()

# First set of models
models_first_set <- foreach(exposure = varlist_exp_all, .packages = c("survival", "broom.mixed")) %dopar% {
  run_model(exposure, df_cco_tmax, "approximate")
}
names(models_first_set) <- varlist_exp_all

all_model_outputs <- models_first_set

# Save the list as an RDS object
saveRDS(all_model_outputs, here(path_processed, "4.5-models-cco-heat-index.rds"))
print("Finished saving all models")
print(Sys.time())
