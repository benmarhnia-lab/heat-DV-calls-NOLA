# Load packages ---- 
rm(list = ls())
library(tidyverse)
library(fst)
library(data.table)
library(janitor)

# Read data ----
## Climate data ----- 
df_climate <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/2.2_nola_temp_zip_code_hw.fst", 
            as.data.table = TRUE)
## NOPD - DV calls data -----
df_dv_agg <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.3-DV-cases-agg.fst", 
                              as.data.table = TRUE)

nrow(df_dv_agg)
# Merge climate and NOPD data ----
## Perform the merge -----
df_nopd_climate_merged <- df_dv_agg |>
                            left_join(df_climate, 
                                by = c("Zip", "year", "month", "weekday"))
head(df_nopd_climate_merged)

## Create a variable to identify DV cases -----
df_nopd_climate_merged <- df_nopd_climate_merged |> 
                                mutate(dv_case = ifelse(case_date == date.y, 1, 0))
sum(is.na(df_nopd_climate_merged$tmax))

# Inspect missing temperature cases ----
df_test <- df_nopd_climate_merged[is.na(tmax)]
unique(df_test$Zip)
# 70118 and 70131 zip codes are missing. These were missing in script 1.4 as well.

# Drop cases with Zip codes 70118 and 70131 ----
df_nopd_climate_merged <- df_nopd_climate_merged |>
                                filter(!Zip %in% c("70118", "70131"))
sum(is.na(df_nopd_climate_merged$tmax))

# Convert from Kelvin to Celcius -----
df_nopd_climate_merged <- df_nopd_climate_merged |>
                            mutate(tmax_cel = tmax - 273.15)
colnames(df_nopd_climate_merged)

# Save work
write_fst(df_nopd_climate_merged, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/3.1-nopd-climate-merged.fst")

