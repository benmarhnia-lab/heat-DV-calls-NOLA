# Load Libraries
library(tidyverse)
library(openxlsx)
library(data.table)
library(fst)

# Read in data
setwd("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/raw-data-extracted/nopd-calls-csvs")

# List all CSV files in the directory
file_list <- list.files(pattern = "\\.csv$")

# Specify the columns you want to read by name or index
cols_to_read <- c("NOPD_Item", "Type_", "TypeText", "Priority", 
                    "TimeCreate", "BLOCK_ADDRESS", "Zip",
                    "Location") # replace with your column names or indices

# Initialize an empty list to store data frames
data_list <- list()

# Loop through the files and read the specified columns
for (file in file_list) {
  df <- fread(file, select = cols_to_read)
  data_list[[file]] <- df
}

# Combine all data frames into a single data frame
combined_df <- do.call(rbind, data_list)

# Create a unique ID using the row number
combined_df <- combined_df %>% 
    mutate(uid = row_number()) |>
    select(uid, everything())

# Save work
write_fst(combined_df, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_raw.fst")

 
#############################################
# Create a unique list of TypeText
type_text <- sort(unique(df_nopd_comb_raw$TypeText))
type_text <- as.data.frame(type_text)
nrow(type_text)
# Save outputs
write.xlsx(type_text, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_call_type_categories.xlsx", sheetName = "call_type_categories")

