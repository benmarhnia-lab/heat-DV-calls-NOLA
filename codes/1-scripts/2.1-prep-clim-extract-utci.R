# This script extracts the maximum tmax data for the zip codes in New Orleans.

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
pacman::p_load(sf, sp, terra, tidyterra, ncdf4, tigris)
# devtools::install_github("axdey/climExposuR")
library(climExposuR)
source("paths-mac.R")

# Step-1: Read Shape file for NOLA zip codes ---- 

## Get the shape file of zip codes using tigris
options(tigris_use_cache = TRUE)
zctas_nola_70 <- tigris::zctas(starts_with = c("70"))

### Check the data
# summary(zctas_nola_70)
# length(zctas_nola_70)
# class(zctas_nola_70) # sf/data-frame
# head(zctas_nola_70)
# length(unique(zctas_nola_70$ZCTA5CE20)) # 319 zip codes
# nrow(zctas_nola_70) #319
# plot(zctas_nola_70[1])


## Get list of Zip codes used in the NOPD-DV ----- 
path_project, "processed-data" <- here(path_project, "processed-data")
df_nopd_dv_cases <- read_fst(here(path_project, "processed-data", "1.4-DV-cases-agg.fst"), as.data.table = TRUE)
zips_nopd_dv <- unique(df_nopd_dv_cases$Zip)
length(zips_nopd_dv) # 29 zip codes

## Retain only those zip codes that are in NOPD-DV data
zctas_nola_nopd <- zctas_nola_70 |> 
                        filter(ZCTA5CE20 %in% zips_nopd_dv) |>
                        mutate(Zip = ZCTA5CE20)
class(zctas_nola_nopd) # sf/data-frame
length(unique(zctas_nola_nopd$Zip)) # 26 zip codes

### Identify zipcodes that are in the NOPD-DV data but not in the shape file
zips_not_in_shape <- setdiff(zips_nopd_dv, zctas_nola_nopd$Zip) # 3 such zip codes
### identify the number of cases in these zip codes
df_nopd_dv_cases |> filter(Zip %in% zips_not_in_shape) |> pull(DV_count) |> sum() # 6 cases

# Load the function
path_function <- here("codes", "2-helper-functions", "function-to-extract-clim-data-tif.R")
source(path_function)

# Extract temperature data for NOLA zip codes ----
df_nola_zip_temp <- process_climate_data(path_clim_files = path_utci,
                                 sf_file = zctas_nola_nopd, 
                                 sf_file_admin = "ZCTA5CE20",
                                 embedded_date_type = "actual",
                                 reference_date = NULL,
                                 start_index = 1,
                                 end_index = NULL,
                                 crs = 4326)

## Create date variable
df_nola_zip_utci <- df_nola_zip_temp |> rownames_to_column(var = "date_string")
df_nola_zip_utci <- df_nola_zip_utci |> select(-date)
df_nola_zip_utci <- df_nola_zip_utci |> mutate(date = ymd(substr(date_string, 1, 8)))

# Rename variables ----
df_nola_zip_utci <- df_nola_zip_utci |> 
                        mutate(Zip = Attribute,
                                utci_mean = clim_daily_mean) |> 
                        select(-Attribute, -clim_daily_mean, -date_string) 

# Check the data ---- 
## Check the dimensions
dim(df_nola_zip_utci) # 319*45*26
# 26*365*54 (26 zip codes * 365 days * 54 years) = 512460

## Check a specific Zip code ----
df_test <- df_nola_zip_utci |> 
                mutate(year = lubridate::year(date)) |>
                mutate(month = lubridate::month(date)) |> 
                filter(Zip == "70126") 
# View(df_test)

# Save file
write_fst(df_nola_zip_utci, here(path_project, "processed-data", "2.1_nola_utci_zip_code.fst"))