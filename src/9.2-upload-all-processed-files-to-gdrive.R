library(googledrive)
library(here)

# Upload all processed data to Google Drive
## Get ID of the folder to upload to
folder_id_upload <- "1aZpF0Vkfst7-A8_yO6hDdzZeYJrGf8D_"

## List all processed files
file_list <- list.files(here("data", "processed-data"), full.names = TRUE)

## Write a loop to upload all files 
for (file in file_list) {
  ## Get the file name
  file_name <- basename(file)
  
  ## Upload the file
  drive_upload(media = file, 
               name = file_name, 
               path = as_id(folder_id_upload),
               overwrite = TRUE)
}