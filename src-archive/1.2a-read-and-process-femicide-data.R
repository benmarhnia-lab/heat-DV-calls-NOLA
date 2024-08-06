pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)

# Load femicide data
path_raw_data_femicide <- here("data", "raw-data", "Louisiana-femicide")
df_femicide_deidentified <- read_csv(file = here(path_raw_data_femicide, "femicide-deidentified.csv"))
head(df_femicide_deidentified)


# Save dataset
path_processed_data <- here("data", "processed-data")
if (!dir.exists(path_processed_data)) {dir.create(path_processed_data, recursive = TRUE)}
write_fst(df_femicide_deidentified, 
    here(path_processed_data, "1.2a-femicide-deidentified.fst"))
