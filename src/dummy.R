library(googledrive)
library(here)

here_wbgt_max_raw <- here("data", "raw-data", "wbgt_max_raw")
if(!dir.exists(here_wbgt_max_raw)) {dir.create(here_wbgt_max_raw, showWarnings = TRUE, recursive = TRUE)}

### Point to the folder on Googledrive
folder_id_tmax_wb <- "1K0MrLG5RhFVnoDOE3F0amlz5CiyTuqQ_"

files_tmax_wb <- googledrive::drive_ls(as_id(folder_id_tmax_wb))

### Download the relevant file to the local folder
for (i in seq_len(nrow(files_tmax_wb))) {
    cur_file <- files_tmax_wb[i, ]
    googledrive::drive_download(as_id(cur_file$id), 
      path = here(here_wbgt_max_raw, cur_file$name))}
