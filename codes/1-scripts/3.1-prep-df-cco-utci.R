# Load packages ----
rm(list = ls())
pacman::p_load(tidyverse, data.table, janitor, fst, beepr, openxlsx, lme4, broom, broom.mixed, here)

# set paths ----
source("paths-mac.R")

# Read data ----
## Climate data -----
df_climate_utci <- read_fst(here(path_project, "processed-data", "2.3-clim-vars-utci.fst"), as.data.table = TRUE)
tabyl(df_climate_utci$rel_hd_rolling_85)
tabyl(df_climate_utci$rel_hw_rolling_85_2d)
tabyl(df_climate_utci$abs_hd_30)
tabyl(df_climate_utci$abs_hw_30_2d)

### Check for missing values ----
sum(is.na(df_climate_utci)) # 0 cases
head(df_climate_utci)

## NOPD - DV calls data -----
df_dv_agg <- read_fst(here(path_project, "processed-data", "1.4-DV-cases-agg.fst"), as.data.table = TRUE)

# View(df_dv_agg |> filter(Zip == 70117))

# Merge NOPD data with climate data ----
head(df_dv_agg)
head(df_climate_utci |> filter(Zip == 70126))
df_nopd_utci_merged <- df_dv_agg |> left_join(df_climate_utci,
                        by = c("Zip", "year", "month", "weekday"))

head(df_nopd_utci_merged)
# Create a variable to identify DV cases -----
df_nopd_utci_merged <- df_nopd_utci_merged |>
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date, "%Y-%m-%d"), 1, 0)
  )

min(df_nopd_utci_merged$date, na.rm = TRUE)
max(df_nopd_utci_merged$date, na.rm = TRUE)
# Check the data -------
# View((df_nopd_utci_merged |> filter(Zip == 70117) |> select(dv_case, Zip, date, case_date, year, month, weekday, utci_max)))

## Inspect missing temperature cases
nrow(df_nopd_utci_merged) # 238,161
colnames(df_nopd_utci_merged)
sum(is.na(df_nopd_utci_merged$utci_max)) # 0 cases

## Drop the missing cases ----
# df_test <- df_nopd_utci_merged |> filter(is.na(utci))
# unique(df_test$Zip)

# df_test |>
#   group_by(Zip) |>
#   summarise(n = n(), .groups = "drop")
# View(df_test)

# View(df_climate_utci |>
#       mutate(year = year(date),
#             month = month(date)) |>
#       filter(Zip == 70119 & year == 2022 & month == 1))

colnames(df_nopd_utci_merged)
max(df_dv_agg$case_date, na.rm = TRUE)
# View(df_nopd_utci_merged)
# Save the data ----
df_nopd_utci_merged |> write_fst(here(path_project, "processed-data", "3.1-cco-data-utci.fst"))
