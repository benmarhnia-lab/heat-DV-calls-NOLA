# Load packages ----
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed)

# Read raw-dv data
rm(list = ls())
df_nopd_dv_cases <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/heat-and-nopd-dv-calls/1.0-nopd-calls-raw-dv-only.fst", 
                                as.data.table = TRUE)
nrow(df_nopd_dv_cases) # 167,042 cases

# Subset of data where zip code is missing
# unique(df_nopd_comb$Zip)
df_missing_zip <- df_nopd_dv_cases |>
    filter(is.na(Zip) | Zip == "None" | Zip == "") 

df_missing_zip <- df_missing_zip[, .(uid, Zip, BLOCK_ADDRESS, Location)]

colnames(df_missing_zip)

## Quick check
nrow(df_missing_zip)

tabyl(df_nopd_dv_cases, Zip)

### The number of missing cases should be:
131+185+593 # 909

## Identify how many of them have missing block and missing location
df_missing_zip_and_block <- df_missing_zip |> dplyr::filter(is.na(BLOCK_ADDRESS)) 
nrow(df_missing_zip_and_block) # There is no such case!

# Save files
## Export missing Zip files to an excel for Namratha and Edwin to fill in
write.csv(df_missing_zip, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/heat-and-nopd-dv-calls/1.1-missing-zips.csv", row.names = FALSE)

