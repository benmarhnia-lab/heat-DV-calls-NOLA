# load library ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, here)
library(performance)

# set paths ----
source("paths-mac.R")

# load models ----
model_outputs <- readRDS(here(path_project, "processed-data", "4.1-models-cco-utci_21.rds"))
print("finished loading models")


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

## Save Tidy Outputs to separate workbooks 
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

## write Step-1 output to a file
saveWorkbook(wb, here(path_project, "outputs", "models", "models_cco_utci_21.xlsx"), overwrite = TRUE)

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

## Save Step-2  output to a CSV 
write.csv(combined_exposures, here(path_project, "outputs", "models", "models_consolidated_cco_utci_21.csv"), row.names = FALSE)

# step-3: calculate attributable fraction ----
## For 90th percentile heatwave for 5 days
or_hw_90_5d <- combined_exposures[which(combined_exposures$exposure == "rel_hw_rolling_90_5d"), "estimate"]
## calculate attributable fraction among exposed
afe <- ((or_hw_90_5d - 1) / or_hw_90_5d)*100
afe # so 6.5% of the DV cases are attributable to heatwaves