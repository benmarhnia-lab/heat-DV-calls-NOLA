# Load packages ---- 
rm(list = ls())
library(tidyverse)
library(fst)
library(data.table)
library(janitor)
library(here)

# Read data ----
path_processed <- here("data", "processed-data")
## Climate data ----- 
df_climate <- read_fst(here(path_processed, "3.1-nola-zip-temp-vars-created.fst"), as.data.table = TRUE)
## NOPD - DV calls data -----
df_dv_agg <- read_fst(here(path_processed, "1.1d-DV-cases-agg.fst"), as.data.table = TRUE)

# Merge climate and NOPD data ----
head(df_dv_agg)
head(df_climate)
## Perform the merge -----
df_nopd_climate_merged <- df_dv_agg |>
                            left_join(df_climate, 
                                by = c("Zip", "year", "month", "weekday"))

View((df_nopd_climate_merged[1:200,]))

## Create a variable to identify DV cases -----
df_nopd_climate_merged <- df_nopd_climate_merged |> 
  mutate(
    dv_case = ifelse(format(case_date, "%Y-%m-%d") == format(date.y, "%Y-%m-%d"), 1, 0)
  )
sum(df_nopd_climate_merged$dv_case)
View((df_nopd_climate_merged[1:200,]))


# Inspect missing temperature cases ----
# df_test <- df_nopd_climate_merged[is.na(wbgt_max)]
# unique(df_test$Zip)
# 70118 and 70131 zip codes are missing. These were missing in script 1.4 as well.

# Drop cases with Zip codes 70118 and 70131 ----
# df_nopd_climate_merged <- df_nopd_climate_merged |> filter(!Zip %in% c("70118", "70131"))
# sum(is.na(df_nopd_climate_merged$tmax))

# Save work
write_fst(df_nopd_climate_merged, here(path_processed, "3.1-nopd-climate-merged.fst"))

