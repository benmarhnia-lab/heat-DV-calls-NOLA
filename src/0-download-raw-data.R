# Load Libraries
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, googledrive, here)
# drive_auth()

# Download all raw datafiles ----------
## Step-1: NOPD DV Calls -------- 
### Create download path
path_raw_data_nopd <- here("data", "raw-data", "nopd-calls-csvs")
if (!dir.exists(path_raw_data_nopd)) {dir.create(path_raw_data_nopd, recursive = TRUE)}

### Point to the NOPD calls folder on Googledrive
folder_id_nopd_dv_calls <- "11E6PzfWEzDt7iTYuCdDK2muqsbE18R2g"

### List all files in the folder
files_nopd <- drive_ls(as_id(folder_id_nopd_dv_calls), pattern = "\\.csv$")

### Download all files in the folder
sapply(1:nrow(files_nopd), function(idx) {
  file_id <- files_nopd$id[idx]
  file_name <- files_nopd$name[idx]
  file_path <- here(path_raw_data_nopd, file_name)  # Construct file path
  drive_download(as_id(file_id), path = file_path, overwrite = TRUE)
})

## Step-2: NOPD missing zips filled by Edwin and Namratha --------
### Create download paths
path_raw_data_femicide <- here("data", "raw-data", "Louisiana-femicide")
if (!dir.exists(path_raw_data_femicide)) {dir.create(path_raw_data_femicide, recursive = TRUE)}
### Point to the NOPD calls folder on Googledrive
file_id_nopd_missing_zips <- "119D5kNdH1kUyYGmcoYNLfKd12QHBI4lu"
### Download the file
drive_download(as_id(file_id_nopd_missing_zips), path = here("data", "raw-data", "nopd-missing-zips-filled-by-Edwin-Namratha.csv"), overwrite = TRUE)

## Step-3: Femicide data --------
### Point to the femicide folder on Googledrive
file_id_femicide_deidentified <- "10u_sBfdqGyDVc6a4YlIgMRvLPCwqN3AS"
drive_download(as_id(file_id_femicide_deidentified), path = here(path_raw_data_femicide, "femicide-deidentified.csv"), overwrite = TRUE)

