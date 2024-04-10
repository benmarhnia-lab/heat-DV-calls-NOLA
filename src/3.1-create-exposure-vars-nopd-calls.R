# Libraries ----
rm(list = ls())
library(tidyverse)
library(fst)
library(data.table)
library(janitor)

# Read data ----
df_temp_data_nola <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/2.1_nola_temp_zip_code.fst", 
                                as.data.table = TRUE)

# Create hotday variable ----
mean(df_temp_data_nola$tmax_cel, na.rm = TRUE)
df_temp_data_nola$hotday_30 <- ifelse(df_temp_data_nola$tmax_cel >= 30, 1, 0)
df_temp_data_nola$hotday_32 <- ifelse(df_temp_data_nola$tmax_cel >= 32, 1, 0)
df_temp_data_nola |> tabyl(hotday_32)

# Create heat-wave variable ----
df_temp_data_nola <- df_temp_data_nola[, 
                        consec_days_32 := ifelse(tmax_cel >= 32, 1:.N, 0L), by = rleid(tmax_cel >= 32)]

df_temp_data_nola <- df_temp_data_nola[,
                        hw_32 := ifelse(consec_days_32 >= 3, 1, 0), by = Zip]

df_temp_data_nola |> tabyl(hw_32)

# Plot heatwave over months ----
df_plot <- df_temp_data_nola |>
                group_by(month) |>
                    summarise(hw_32 = sum(hw_32, na.rm = TRUE)) |>
                    ungroup()
head(df_plot)

plot_1 <- ggplot(df_plot, aes(x = month, y = hw_32)) +
            geom_line() +
            labs(x = "Month", y = "Number of heatwaves", title = "Number of heatwaves across months") +
            theme_bw() +
            theme(plot.title = element_text(hjust = 0.5))
plot_1

# Save data ----
write_fst(df_temp_data_nola, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/2.2_nola_temp_zip_code_hw.fst")
