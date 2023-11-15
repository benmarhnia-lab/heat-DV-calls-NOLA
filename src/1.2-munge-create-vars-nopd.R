# Load packages
library(tidyverse)
library(fst)
library(data.table)

# Read data
rm(list = ls())
df_nopd_vars_crtd <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_raw.fst", as.data.table = TRUE)
# Identify cases that may be Domestic Violence related ----- 
## Based on this report: https://nopdnews.com/getattachment/Transparency/Policing-Data/Data/Domestic-Violence/2019-Domestic-Violence-Annual-Report.pdf/?lang=en-US
## Another resource shared by Melissa: https://nopdnews.com/transparency/policing-data/

## List of call types that may be Domestic Violence related
list_call_type_DV <- c("AGGRAVATED ASSAULT DOMESTIC", "AGGRAVATED BATTERY DOMESTIC",  "HOMICIDE DOMESTIC",
                        "CRIMINAL DAMAGE DOMESTIC", "DOMESTIC DISTURBANCE", "DOMESTIC VIOLENCE", "EXTORTION (THREATS) DOMESTIC", 
                        "SIMPLE ASSAULT DOMESTIC",  "SIMPLE BATTERY DOMESTIC", "SIMPLE BURGLARY DOMESTIC")

## Create a new column to identify cases that may be Domestic Violence related -----
df_nopd_vars_crtd <- df_nopd_vars_crtd |> 
    mutate(DV_related = ifelse(TypeText %in% list_call_type_DV, 1, 0))

## Check percentage ----- 
df_nopd_comb_vars_crtd |>
    janitor::tabyl(DV_related) 

# Create a variables for year, month and day ---- 
## Convert TimeCreate to date format ----- 
df_nopd_vars_crtd <- df_nopd_vars_crtd |> 
    mutate(date = as.Date(TimeCreate, format = "%m/%d/%Y"))

## Create variables for year and month ----- 
df_nopd_vars_crtd <- df_nopd_vars_crtd[, ':=' (
                        year = lubridate::year(date),
                        month = lubridate::month(date))]

# df_nopd_vars_crtd |> janitor::tabyl(year)

# Save work
write_fst(df_nopd_vars_crtd, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_comb_vars_crtd.fst")
