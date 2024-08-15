# This script extracts the maximum tmax data for the zip codes in New Orleans.

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
pacman::p_load(sf, sp, terra, tidyterra, ncdf4, tigris)
devtools::install_github("axdey/climExposuR")
library(climExposuR)
source(here(".Rprofile"))

# Step-1: Read Shape file for NOLA zip codes ---- 

## Get the shape file of zip codes using tigris
options(tigris_use_cache = TRUE)
zctas_nola_70 <- tigris::zctas(starts_with = c("70"))

### Check the data
summary(zctas_nola_70)
length(zctas_nola_70)
class(zctas_nola_70) # sf/data-frame
head(zctas_nola_70)
length(unique(zctas_nola_70$ZCTA5CE20)) # 319 zip codes
nrow(zctas_nola_70) #319
# plot(zctas_nola_70[1])


## Get list of Zip codes used in the NOPD-DV ----- 
path_processed_data <- here(path_project, "processed-data")
df_nopd_dv_cases <- read_fst(here(path_processed_data, "1.4-DV-cases-agg.fst"), as.data.table = TRUE)
zips_nopd_dv <- unique(df_nopd_dv_cases$Zip)
length(zips_nopd_dv) # 29 zip codes

## Retain only those zip codes that are in NOPD-DV data
zctas_nola_nopd <- zctas_nola_70 |> 
                        filter(ZCTA5CE20 %in% zips_nopd_dv) |>
                        mutate(Zip = ZCTA5CE20)
class(zctas_nola_nopd)
length(unique(zctas_nola_nopd$Zip)) # 26 zip codes

### Identify zipcodes that are in the NOPD-DV data but not in the shape file
zips_not_in_shape <- setdiff(zips_nopd_dv, zctas_nola_nopd$Zip) # 3 such zip codes
### identify the number of cases in these zip codes
df_nopd_dv_cases |> filter(Zip %in% zips_not_in_shape) |> pull(DV_count) |> sum() # 6 cases

# Load the function
# path_function <- here("codes", "2-helper-functions", "function-to-extract-climate-data-multiple-nic-files.R")
# source(path_function)

# Extract temperature data for NOLA zip codes ----
df_nola_zip_temp <- climExposuR::func_extract_clim_data_shp(path_nic_files = path_tmax_noaa, 
                                 sf_file = zctas_nola_nopd, 
                                 sf_file_admin = "Zip")

head(df_nola_zip_temp)

# Rename variables ----
df_nola_zip_temp <- df_nola_zip_temp |> 
                        mutate(Zip = Attribute,
                                tmax = clim_daily_mean) |> 
                        select(-Attribute, -clim_daily_mean)

head(df_nola_zip_temp)


# Save file
write_fst(df_nola_zip_temp, here(path_processed_data, "2.1_nola_tmax_zip_code.fst"))
# df_nola_zip_tmax <- read_fst(here(path_processed_data, "2.1_nola_tmax_zip_code.fst"), as.data.table = TRUE)

# Diagnostics
head(df_nola_zip_temp)
dim(df_nola_zip_temp)
26*365*45
