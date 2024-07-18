# Library ----
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)
library(performance)
rm(list = ls())

# Create a folder for the outputs ----
path_out <- here("outputs", "models", "models-cco-heat-index")
if (!dir.exists(path_out)) {
  # Create the directory if it does not exist
  dir.create(path_out, showWarnings = TRUE, recursive = TRUE)
}

# Load models ----
path_processed <- here("data", "processed-data")
model_outputs <- readRDS(here(path_processed, "4.5-models-cco-heat-index.rds"))
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
# Run only for interaction models
# dput(names_tidy_outputs)
# ## Create a substring 
# # substrings <- str_extract(names_tidy_outputs, "(?<=~\\s)[^+]+")
# substrings <- str_sub(names_tidy_outputs, start = 20, end = 40)
# ## Assign new names 
# names(tidy_outputs) <- substrings

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
saveWorkbook(wb, here(path_out, "models_cco_heat_index.xlsx"), overwrite = TRUE)

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
  estimates <- round(model[c(2,6,7)], 2)
  
  # Combine the exposure and the estimates
  second_row <- cbind(exposure, estimates)

  # Append the extracted row to the combined dataframe
  combined_exposures <- rbind(combined_exposures, second_row)
}

head(combined_exposures)
## Save Step-2  output to a CSV ----
write.csv(combined_exposures, here(path_out, "models_consolidated_cco_heat_index.csv"), row.names = FALSE)

