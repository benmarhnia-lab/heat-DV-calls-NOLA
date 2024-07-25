# Load packages ---- 
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)

# constants ----
path_processed <- here("data", "processed-data")

# Read data ----
## Climate data ----- 
df_climate_tmax <- read_fst(here(path_processed, "2.3-clim-vars-tmax.fst"), as.data.table = TRUE)
## NOPD - DV calls data -----
df_dv_agg <- read_fst(here(path_processed, "1.4-DV-cases-agg.fst"), as.data.table = TRUE)


# View(df_dv_agg |> filter(Zip == 70117))

# Merge NOPD data with climate data ----
head(df_dv_agg)
head(df_climate_tmax)
df_nopd_tmax_merged <- df_dv_agg |> left_join(df_climate_tmax, 
                        by = c("Zip", "year", "month", "weekday"))

# Create a variable to identify DV cases -----
df_nopd_tmax_merged <- df_nopd_tmax_merged |> 
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date, "%Y-%m-%d"), 1, 0)
  )

# Check the data -------
# View((df_nopd_tmax_merged |> filter(Zip == 70117) |> select(dv_case, Zip, date, case_date, year, month, weekday, tmax)))

## Inspect missing temperature cases
nrow(df_nopd_tmax_merged) # 264,383
sum(is.na(df_nopd_tmax_merged$tmax)) # 3 cases
df_test <- df_nopd_tmax_merged[is.na(tmax)]
unique(df_test$Zip)

#' 70118 and 70133, 70144 zip codes are missing. 
#' Look for these in the climate data
df_climate_tmax |> filter(Zip == 70188) 
df_climate_tmax |> filter(Zip == 70133) 
df_climate_tmax |> filter(Zip == 70144) 

#' these cases are missing in the climate data as well

## Drop the missing cases ----
df_nopd_tmax_merged <- df_nopd_tmax_merged |> filter(!is.na(tmax))
nrow(df_nopd_tmax_merged) # 264380

# Save the data ----
write_fst(df_nopd_tmax_merged, here(path_processed, "3.1-cco-data-tmax.fst"))

