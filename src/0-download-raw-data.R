# Load Libraries
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, googledrive, here)
# drive_auth()

# NOPD DV Calls Raw -------- 
## Create download path
path_raw_data_nopd <- here("data", "raw-data", "nopd-calls-csvs")
if (!dir.exists(path_raw_data_nopd)) {dir.create(path_raw_data_nopd, recursive = TRUE)}

## Point to the NOPD calls folder on Googledrive
folder_id_nopd_dv_calls <- "11E6PzfWEzDt7iTYuCdDK2muqsbE18R2g"

## List all files in the folder
files_nopd <- drive_ls(as_id(folder_id_nopd_dv_calls), pattern = "\\.csv$")

## Download all files in the folder
sapply(1:nrow(files_nopd), function(idx) {
  file_id <- files_nopd$id[idx]
  file_name <- files_nopd$name[idx]
  file_path <- here(path_raw_data_nopd, file_name)  # Construct file path
  drive_download(as_id(file_id), path = file_path, overwrite = TRUE)
})

# NOPD missing zips filled by Edwin and Namratha --------
### Create download paths
path_raw_data_missing_zips <- here("data", "raw-data")
if (!dir.exists(path_raw_data_missing_zips)) {dir.create(path_raw_data_missing_zips, recursive = TRUE)}
### Point to the folder on Googledrive
file_id_nopd_missing_zips <- "119D5kNdH1kUyYGmcoYNLfKd12QHBI4lu"
### Download the file
drive_download(as_id(file_id_nopd_missing_zips), path = here(path_raw_data_missing_zips, "nopd-missing-zips-filled-by-Edwin-Namratha.csv"), overwrite = TRUE)

# Download processed data -----
## Create download paths
path_processed_data <- here("data", "processed-data")
if (!dir.exists(path_processed_data)) {dir.create(path_processed_data, recursive = TRUE)}

## Point to the folder on Googledrive
folder_id_processed_data <- "1INg5vRLLBNZskykxmKpUYc2LCjij5Ej1"

## List all files in the folder
files_processed_data <- drive_ls(as_id(folder_id_processed_data), pattern = "\\.fst$")
## Download all files in the folder
sapply(1:nrow(files_processed_data), function(idx) {
  file_id <- files_processed_data$id[idx]
  file_name <- files_processed_data$name[idx]
  file_path <- here(path_processed_data, file_name)  # Construct file path
  drive_download(as_id(file_id), path = file_path, overwrite = TRUE)
})

# Download WBGT data -----
## Create download paths
path_raw_data_wbgt <- here("data", "raw-data", "wbgt-ecmwf")
if (!dir.exists(path_raw_data_wbgt)) {dir.create(path_raw_data_wbgt, recursive = TRUE)}

## Point to the folder on Googledrive
folder_id_wbgt_data <- "1F6t_hXslNXetPKpeNI8SfPskLoXHh41_"

## List all files in the folder
files_wbgt_data <- drive_ls(as_id(folder_id_wbgt_data))
## Download all files in the folder
sapply(1:nrow(files_wbgt_data), function(idx) {
  file_id <- files_wbgt_data$id[idx]
  file_name <- files_wbgt_data$name[idx]
  file_path <- here(path_raw_data_wbgt, file_name)  # Construct file path
  drive_download(as_id(file_id), path = file_path, overwrite = TRUE)
})

# Download heat index data -----
## Create download paths
path_raw_data_heat_index <- here("data", "raw-data", "heat-index-ecmwf")
if (!dir.exists(path_raw_data_heat_index)) {dir.create(path_raw_data_heat_index, recursive = TRUE)}

## Point to the folder on Googledrive
folder_id_heat_index_data <- "1F53KKvcY7IrB5sphYUpwD14aMU5sL7ye"

## List all files in the folder
files_heat_index_data <- drive_ls(as_id(folder_id_heat_index_data))
## Download all files in the folder
sapply(1:nrow(files_heat_index_data), function(idx) {
  file_id <- files_heat_index_data$id[idx]
  file_name <- files_heat_index_data$name[idx]
  file_path <- here(path_raw_data_heat_index, file_name)  # Construct file path
  drive_download(as_id(file_id), path = file_path, overwrite = TRUE)
})


