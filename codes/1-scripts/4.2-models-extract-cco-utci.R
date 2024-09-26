# Library ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)
library(performance)
source("paths-mac.R")

# Create a folder for the outputs ----
path_out <- here(path_project, "outputs", "models", "models-cco-utci")
if (!dir.exists(path_out)) {
  # Create the directory if it does not exist
  dir.create(path_out, showWarnings = TRUE, recursive = TRUE)
}

# Load models ----
path_processed <- here(path_project, "processed-data")
model_outputs <- readRDS(here(path_processed, "4.1-models-cco-utci.rds"))

print("finished loading models")
names(model_outputs)


# Step-1: Extract Tidy Outputs  ----

## Initialize an empty list to store tidy outputs
tidy_outputs <- list()

# Iterate over model_outputs to generate tidy outputs using broom.mixed::tidy()
for(exposure in names(model_outputs)) {
  model <- model_outputs[[exposure]]
  tidy_outputs[[exposure]] <- broom.mixed::tidy(model, exponentiate = TRUE, conf.int = TRUE, conf.level = 0.95)
  print(paste0("finished processing", exposure))
}

names_tidy_outputs <- names(tidy_outputs)
substring <- str_sub(names_tidy_outputs, start = 1, end = 30)
names(tidy_outputs) <- substring

## Save Tidy Outputs to separate workbooks ----- 
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

## Write Step-1 output to a file
saveWorkbook(wb, here(path_out, "models_cco_utci.xlsx"), overwrite = TRUE)

# Step-2: Consolidate coefficients for the primary exposure  in a single CSV ----
## Initialize an empty dataframe to store the estimates for the exposure
combined_exposures <- data.frame(a = integer(), b = integer())

## Loop through each model in the list

for(model_name in names(tidy_outputs)) {
  # Extract the model from the list
  model <- tidy_outputs[[model_name]]

  # Extract the 2nd row and the 3rd, 4th, 8th and 9th column from the current model
  exposure <- model_name
  print(exposure)
  estimates <- round(model[c(2,3,6,7)], 2)
  
  # Combine the exposure and the estimates
  second_row <- cbind(exposure, estimates)

  # Append the extracted row to the combined dataframe
  combined_exposures <- rbind(combined_exposures, second_row)
}

head(combined_exposures)
## Save Step-2  output to a CSV ----
write.csv(combined_exposures, here(path_out, "models_consolidated_cco_utci.csv"), row.names = FALSE)
