# This script extracts the Heat Index data for the zip codes in New Orleans.

# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
pacman::p_load(sf, sp, terra, tidyterra, ncdf4, tigris)

# Step-1: Read Shape file for NOLA zip codes ---- 
## Get the shape file of zip codes using tigris
options(tigris_use_cache = TRUE)
zctas_nola_70 <- tigris::zctas(starts_with = c("70"))
class(zctas_nola_70) # sf/data-frame
# plot(zctas_nola_70[1])
nrow(zctas_nola_70)
length(unique(zctas_nola_70$ZCTA5CE20))

## Get list of Zip codes used in the NOPD-DV ----- 
path_processed_data <- here("data", "processed-data")
df_nopd_dv_cases <- read_fst(here(path_processed_data, "1.1d-DV-cases-agg.fst"), as.data.table = TRUE)
zips_nopd_dv <- unique(df_nopd_dv_cases$Zip)
length(zips_nopd_dv) # 17 zip codes

## Retain only those zip codes that are in NOPD-DV data
zctas_nola_nopd <- zctas_nola_70 |> 
                        filter(ZCTA5CE20 %in% zips_nopd_dv) |>
                        mutate(Zip = ZCTA5CE20)
class(zctas_nola_nopd)
length(unique(zctas_nola_nopd$Zip)) # 17 zip codes

# Load the function
path_function <- here("src", "8.1-function-to-extract-climate-data-single-nic-file.R")
source(path_function)

# Extract temperature data for NOLA zip codes ----
path_wbgt_data <- here("data", "raw-data", "heat-index") 
df_nola_zip_temp <- func_extract_clim_data_shp(path_nic_files = path_wbgt_data, 
                                 sf_file = zctas_nola_nopd, 
                                 sf_file_admin = "Zip",
                                 nic_file_name = "heat_index_daily.nc")

head(df_nola_zip_temp)

# Rename variables ----
df_nola_zip_temp <- df_nola_zip_temp |> 
                        mutate(Zip = Attribute,
                                heat_index = clim_daily_mean)

# Save file
write_fst(df_nola_zip_temp, here(path_processed_data, "2.1_nola_heat_index_zip_code.fst"))

