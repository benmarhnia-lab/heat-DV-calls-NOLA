# Load processed files from BEL server 

library(here)
library(googledrive)

# Point to the folder on Googledrive
folder_id_upload <- "1aZpF0Vkfst7-A8_yO6hDdzZeYJrGf8D_"
files_processed <- googledrive::drive_ls(as_id(folder_id_upload))

# path to local folder
here_wbgt_max_raw <- here("data", "processed-data")
### Download the relevant file to the local folder

for (i in seq_len(nrow(files_processed))) {
    cur_file <- files_tmax_wb[i, ]
    googledrive::drive_download(as_id(cur_file$id), 
      path = here(here_wbgt_max_raw, cur_file$name), 
      overwrite = TRUE)}
