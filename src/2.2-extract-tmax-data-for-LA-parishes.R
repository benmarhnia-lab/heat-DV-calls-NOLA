# This script extracts the maximum WB temperature data for the counties in Loisiana.

# Load packages ----
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, here)
pacman::p_load(sf, sp, terra, tidyterra, ncdf4, tigris)
rm(list = ls())

# Step-1: Read Shape file for NOLA zip codes ---- 
## Get the shape file of counties in Louisiana ----
counties_la <- tigris::counties(state = "LA")
class(counties_la)
plot(counties_la[1])
nrow(counties_la)
length(unique(counties_la$NAME)) # 64 unique counties in LA

## Get list of Counties used in the Femicide data ----- 
path_processed_data <- here("data", "processed-data")
df_femicide <- read_fst(here(path_processed_data, "1.2a-femicide-deidentified.fst"), as.data.table = TRUE)
parish_femicide <- unique(df_femicide$parish)
length(parish_femicide) # 58 Parishes with Femicide data

## Compare names of counties in the femicide data and the shape file
parish_femicide <- sort(tolower(parish_femicide))
county_shp <- sort(tolower(counties_la$NAME))
### Counties that are present in the femicide data but not in the shape file
setdiff(parish_femicide, county_shp) # 0
### Counties that are present in the shape file but not in the femicide data
setdiff(county_shp, parish_femicide) # 6 -> these are parishes where there was no femicide reported 

## Retain only those zip codes that are in NOPD-DV data
counties_la_femicide <- counties_la |> 
                        filter(tolower(NAME) %in% parish_femicide) |>
                        mutate(county_name = NAME)
plot(counties_la_femicide)
length(unique(counties_la_femicide$county_name)) # 58 counties

# Load the function
path_function <- here("src", "8.1-function-to-extract-climate-data.R")
source(path_function)

# Extract temperature data for NOLA zip codes ----
path_wbgt_data <- here("data", "raw-data", "wbgt_max_raw") 
df_LA_county_temp <- func_extract_clim_data_shp(path_nic_files = path_wbgt_data, 
                                 sf_file = counties_la_femicide, 
                                 sf_file_admin = "county_name")

dim(df_nola_zip_temp)                                 
365*5*58 # 105850

# Rename variables ----
df_LA_county_temp <- df_LA_county_temp |> 
                        mutate(County = Attribute,
                                wbgt_max = clim_daily_mean)

# Save file
write_fst(df_LA_county_temp, here(path_processed_data, "2.2_LA_temp_county.fst"))

