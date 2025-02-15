# -------------------------------------------------------------------------------
# @project: Extreme heat and domestic violenve related service calls in New Orleans
# @author: Arnab K. Dey (arnabxdey@gmail.com)
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script extracts the coefficients from the models for the CCO analysis
# @date: Feb 4, 2025

# load library ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, openxlsx, here)

# load models ----
model_outputs <- readRDS(here("Data", "2.1_models_cco_utci.rds"))

# step-1: extract tidy outputs  ----
## initialize an empty list to store tidy outputs
tidy_outputs <- list()

## Iterate over model_outputs to generate tidy outputs using broom.mixed::tidy()
for(exposure in names(model_outputs)) {
  model <- model_outputs[[exposure]]
  tidy_outputs[[exposure]] <- broom.mixed::tidy(model, exponentiate = TRUE, conf.int = TRUE, conf.level = 0.95)
  print(paste0("finished processing", exposure))
}

## rename the columns of the tidy outputs
names_tidy_outputs <- names(tidy_outputs)
substring <- str_sub(names_tidy_outputs, start = 1, end = 30)
names(tidy_outputs) <- substring

## save tidy outputs to separate workbooks 
### Create a new workbook
wb <- createWorkbook()
### Iterate over the tidy_outputs to add each to a new sheet in the workbook
for(exposure in names(tidy_outputs)) {
  # Create a new sheet with the name of the exposure
  addWorksheet(wb, exposure)
  # Write the tidy output to the sheet
  writeData(wb, exposure, tidy_outputs[[exposure]])
  print(paste0("finished writing", exposure))
}

## write step-1 output to a file
saveWorkbook(wb, here("Data", "2.2_model_coefs.xlsx"), overwrite = TRUE)

# step-2: consolidate coefficients for the primary exposure in a single CSV ----
## initialize an empty dataframe to store the estimates for the exposure
combined_exposures <- data.frame(a = integer(), b = integer())

## loop through each model in the list
for(model_name in names(tidy_outputs)) {
  # extract the model from the list
  model <- tidy_outputs[[model_name]]

  # extract the 2nd row and the 3rd, 4th, 8th and 9th column from the current model
  exposure <- model_name
  print(exposure)
  estimates <- round(model[c(2,3,6,7)], 2)
  
  # combine the exposure and the estimates
  second_row <- cbind(exposure, estimates)

  # append the extracted row to the combined dataframe
  combined_exposures <- rbind(combined_exposures, second_row)
}

## save consolidated output to a csv
combined_exposures |> write.csv(here("Data", "2.2_model_coefs_consolidated.csv"), row.names = FALSE)
