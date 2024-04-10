# This script deletes the downloaded data folder if it exists
# Run this only when all data needed for processing the analysis have been created

library(here)

path_raw_data <- here("data", "raw-data")
if (dir.exists(path_raw_data)) {
  # Delete the directory if it exists
  unlink(path_raw_data, recursive = TRUE)
}