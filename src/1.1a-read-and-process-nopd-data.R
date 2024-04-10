# This script does the following:
# Step-1: reads all DV files, saves an fst file with ALL call records 
# Step-2: creates and saves a subset of calls data that have only DV related cases. 
# Step-3: It also creates a list of unique call types and saves it as an xlsx file.

# Load Libraries
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
# drive_auth()

# Step-1: Read and Process NOPD DV calls data
## Point to the path where the NOPD calls are stored
path_grive_temp_nopd <- here("data", "raw-data", "nopd-calls-csvs")

## List all CSV files in the directory
file_list <- list.files(path_grive_temp_nopd, pattern = "\\.csv$")

## Specify the columns you want to read by name or index
cols_to_read <- c("NOPD_Item", "Type_", "TypeText", "Priority", 
                    "TimeCreate", "BLOCK_ADDRESS", "Zip",
                    "Location") # replace with your column names or indices

## Initialize an empty list to store data frames
data_list <- list()

## Loop through the files and read the specified columns
for (file in file_list) {
  full_path <- here(path_grive_temp_nopd, file)  # Create the full path to the file
  df <- fread(full_path, select = cols_to_read)  # Read the file
  data_list[[file]] <- df  # Store the data frame in the list
}

## Combine all data frames into a single data frame
combined_df <- do.call(rbind, data_list)

## Create a unique ID using the row number
combined_df <- combined_df %>% 
    dplyr::mutate(uid = row_number()) |>
    dplyr::select(uid, everything())

## Save work for Step-1
path_processed_data <- here("data", "processed-data")
if (!dir.exists(path_processed_data)) {dir.create(path_processed_data, recursive = TRUE)}
write_fst(combined_df, here(path_processed_data, "1.1a-nopd-calls-raw-all.fst"))

# Step-2: Subset data to retain DV cases only
## List of call types that may be Domestic Violence related
## Based on this report: https://nopdnews.com/getattachment/Transparency/Policing-Data/Data/Domestic-Violence/2019-Domestic-Violence-Annual-Report.pdf/?lang=en-US
## Another resource shared by Melissa: https://nopdnews.com/transparency/policing-data/

list_call_type_DV <- c("AGGRAVATED ASSAULT DOMESTIC", "AGGRAVATED BATTERY DOMESTIC",  "HOMICIDE DOMESTIC",
                        "CRIMINAL DAMAGE DOMESTIC", "DOMESTIC DISTURBANCE", "DOMESTIC VIOLENCE", "EXTORTION (THREATS) DOMESTIC", 
                        "SIMPLE ASSAULT DOMESTIC",  "SIMPLE BATTERY DOMESTIC", "SIMPLE BURGLARY DOMESTIC")

## Create a new column to identify cases that may be Domestic Violence related -----
df_nopd_dv_cases <- combined_df |> 
    mutate(DV_related = ifelse(TypeText %in% list_call_type_DV, 1, 0)) |>
    filter(DV_related == 1)
nrow(df_nopd_dv_cases)

## Save work for step-2
write_fst(df_nopd_dv_cases, here(path_processed_data, "1.1a-nopd-calls-raw-dv-only.fst"))

# Step-3: Create a unique list of TypeText
type_text <- sort(unique(combined_df$TypeText))
type_text <- as.data.frame(type_text)
nrow(type_text)
## Save outputs
write.xlsx(type_text, here(path_processed_data, "1.1a-nopd-call-type-categories.xlsx"), 
  sheetName = "call_type_categories")
