# Load packages ----
library(tidyverse)
library(fst)
library(janitor)

# Read data
rm(list = ls())
df_nopd_dv_cases <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.0-dv_cases_only.fst", 
                                as.data.table = TRUE)
nrow(df_nopd_dv_cases)

# Subset of data where zip code is missing
# unique(df_nopd_comb$Zip)
df_missing_zip <- df_nopd_dv_cases |>
    filter(is.na(Zip) | Zip == "None" | Zip == "") 

df_missing_zip <- df_missing_zip[, .(uid, Zip, BLOCK_ADDRESS, Location)]

colnames(df_missing_zip)

## Quick check
nrow(df_missing_zip)

df_nopd_dv_cases |>
    janitor::tabyl(Zip)

### The number of missing cases should be:
131+185+593 # 909

## Identify how many of them have missing block and missing location
df_missing_zip |>
    dplyr::filter(is.na(BLOCK_ADDRESS)) 
head(df_missing_zip)

# Export this to an excel for Namratha and Grace
write.csv(df_missing_zip, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/outputs/1.1_missing_zips.csv", row.names = FALSE)
