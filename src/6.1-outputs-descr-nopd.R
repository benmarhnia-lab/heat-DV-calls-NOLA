# Library
rm(list = ls())
library(tidyverse)
library(fst)
library(data.table)
library(janitor)
library(here)

# Read data ----
## Full Data -----

## NOPD - DV calls data -----
df_nopd_vars_crtd <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_vars_crtd.fst")

## DV aggregated data -----
df_dv_agg <- read_fst(here(path_processed, "1.4-DV-cases-agg.fst"), as.data.table = TRUE)
df_dv_agg <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/1.3-DV-cases-agg.fst", 
                              as.data.table = TRUE)


# Crosstab of DV reporting across years ---- 
tab_1 <- df_nopd_vars_crtd |>
            tabyl(year, DV_related) |>
            adorn_totals("row") |>
            adorn_percentages("row") |>
            adorn_pct_formatting(digits = 2) |>
            adorn_ns(position = "front") |>
            adorn_title("top")

# write.csv(tab_1, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/outputs/dv_calls_over_years.csv", row.names = FALSE)

# Plot number of DV cases across months -----
colnames(df_dv_agg)

df_plot_1 <- df_dv_agg |>
                group_by(month) |>
                    summarise(dv_cases = sum(DV_count))
                    ungroup()

plot_1 <- ggplot(df_plot_1, aes(x = month, y = dv_cases)) +
            geom_line() +
            labs(x = "Month", y = "Number of DV cases", title = "Number of DV cases across months") +
            theme_bw() +
            theme(plot.title = element_text(hjust = 0.5))                    

plot_1
