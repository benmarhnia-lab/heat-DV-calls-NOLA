# Load packages ---- 
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)

# constants ----
path_processed <- here("data", "processed-data")

# Read data ----
## Climate data ----- 
df_climate_tmax <- read_fst(here(path_processed, "2.6-clim-vars-wbgt.fst"), as.data.table = TRUE)
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
# View((df_nopd_tmax_merged |> filter(Zip == 70117) |> select(dv_case, Zip, date, case_date, year, month, weekday, wbgt_max)))

## Inspect missing temperature cases
nrow(df_nopd_tmax_merged) # 264,338
sum(is.na(df_nopd_tmax_merged$tmax)) # 0 cases


# Save the data ----
write_fst(df_nopd_tmax_merged, here(path_processed, "3.2-cco-data-wbgt.fst"))

