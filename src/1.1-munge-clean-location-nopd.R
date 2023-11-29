# Load packages ----
library(tidyverse)
library(fst)
library(janitor)

# Read data
rm(list = ls())
df_nopd_comb <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_raw.fst")
nrow(df_nopd_comb)
# Subset of data where zip code is missing
# unique(df_nopd_comb$Zip)
df_missing_zip <- df_nopd_comb %>% 
    filter(is.na(Zip) | Zip == "None" | Zip == "") |>
    select(uid, Zip, BLOCK_ADDRESS, Location)

## Quick check
df_nopd_comb |>
    janitor::tabyl(Zip)
### The number of missing cases should be:
6618+30119+66441 # 103178
nrow(df_missing_zip)

## Identify how many of them have missing block and missing location
df_missing_zip |>
    dplyr::filter(is.na(BLOCK_ADDRESS)) 
head(df_missing_zip)

## Separate Lat and Long
### Split the 'location' column into 'lat' and 'long'
df_missing_zip$Location_new <- gsub("[()]", "", df_missing_zip$Location)  # Remove parentheses
coordinates <- strsplit(df_missing_zip$Location_new, ", ")  # Split by comma and space

### Create 'lat' and 'long' columns
df_missing_zip$lat <- as.numeric(sapply(coordinates, function(x) x[1]))
df_missing_zip$long <- as.numeric(sapply(coordinates, function(x) x[2]))

## Number of cases where lat long is not usable
df_latlong_unusable <- df_missing_zip |>
    filter(long > -89.7891)

## Number of cases where lat long is usable
df_latlong_usable <- df_missing_zip |>
    filter(!uid %in% df_latlong_unusable$uid)

## Check
nrow(df_latlong_unusable) + nrow(df_latlong_usable) == nrow(df_missing_zip)

# Save your work
## Export this to an excel for Namratha and Grace
# write.csv(df_latlong_unusable, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/outputs/latlong_unusable.csv", row.names = FALSE)
write_fst(df_latlong_usable, path = "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_zip_missing_w_latlong.fst")
