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
    dplyr::mutate(uid = row_number()) |>
    dplyr::select(uid, everything())

# Save work
write_fst(combined_df, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.0-nopd_calls_comb_raw.fst")
nrow(combined_df)

# Subset data to retain DV cases only
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

# Save Work
write_fst(df_nopd_dv_cases, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.0-dv_cases_only.fst")

#############################################
# Create a unique list of TypeText
type_text <- sort(unique(combined_df$TypeText))
type_text <- as.data.frame(type_text)
nrow(type_text)
# Save outputs
write.xlsx(type_text, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_call_type_categories.xlsx", sheetName = "call_type_categories")
