# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, googledrive, here)
source("paths-mac.R")

# constants ----
path_processed <- here(path_project, "processed-data")

# Read data ----
## Climate data -----
df_climate_wbgt <- read_fst(here(path_processed, "2.6-clim-vars-wbgt.fst"), as.data.table = TRUE)

### Check for missing values ----
sum(is.na(df_climate_wbgt$wbgt_max)) # 0 cases
head(df_climate_wbgt)

## NOPD - DV calls data -----
df_dv_agg <- read_fst(here(path_processed, "1.4-DV-cases-agg.fst"), as.data.table = TRUE)

# View(df_dv_agg |> filter(Zip == 70117))

# Merge NOPD data with climate data ----
head(df_dv_agg)
head(df_climate_wbgt)
df_nopd_wbgt_merged <- df_dv_agg |> left_join(df_climate_wbgt,
                        by = c("Zip", "year", "month", "weekday"))

# Create a variable to identify DV cases -----
df_nopd_wbgt_merged <- df_nopd_wbgt_merged |>
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date, "%Y-%m-%d"), 1, 0)
  )

min(df_nopd_wbgt_merged$date, na.rm = TRUE)
max(df_nopd_wbgt_merged$date, na.rm = TRUE)
# Check the data -------
# View((df_nopd_wbgt_merged |> filter(Zip == 70117) |> select(dv_case, Zip, date, case_date, year, month, weekday, wbgt_max)))

## Inspect missing temperature cases
nrow(df_nopd_wbgt_merged) # 238,161
colnames(df_nopd_wbgt_merged)
sum(is.na(df_nopd_wbgt_merged$wbgt_max)) # 0 cases

## Drop the missing cases ----
df_test <- df_nopd_wbgt_merged |> filter(is.na(wbgt_max))
unique(df_test$Zip)

df_test |>
  group_by(Zip) |>
  summarise(n = n(), .groups = "drop")
# View(df_test)

# View(df_climate_wbgt |>
#       mutate(year = year(date),
#             month = month(date)) |>
#       filter(Zip == 70119 & year == 2022 & month == 1))

colnames(df_nopd_wbgt_merged)
max(df_dv_agg$case_date, na.rm = TRUE)

# Save the data ----
write_fst(df_nopd_wbgt_merged, here(path_processed, "3.2-cco-data-wbgt.fst"))

