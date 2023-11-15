# Library
library(tidyverse)
library(fst)
library(data.table)
library(janitor)

# Read data
rm(list = ls())
df_nopd_vars_crtd <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_vars_crtd.fst")

# Crosstab of DV reporting across years
tab_1 <- df_nopd_vars_crtd |>
            tabyl(year, DV_related) |>
            adorn_totals("row") |>
            adorn_percentages("row") |>
            adorn_pct_formatting(digits = 2) |>
            adorn_ns(position = "front") |>
            adorn_title("top")

write.csv(tab_1, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/outputs/dv_calls_over_years.csv", row.names = FALSE)
