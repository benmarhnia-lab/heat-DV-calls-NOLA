rm(list =ls())
options(scipen=999)
options(digits=5)
pacman::p_load(tidyverse, ggpubr, ggplot2, sjPlot, readxl, here, extrafont, ggbreak, patchwork)
source("paths-mac.R")

# font_import() # run only once
# loadfonts(device="win") # run only once

# Load data ----
here_output_files <- here(path_project, "outputs", "models", "models-cco-utci")
df_full_models <- read.csv(here(here_output_files, "models_consolidated_cco_utci.csv"))
head(df_full_models)

# Constants ---------------
## Call the function to plot ----
source(here("codes", "2-helper-functions", "function-to-plot-models-and-effect-modifiers.R"))

## Path for outputs ----
path_out <- here(path_project, "outputs", "figures", "cco-utci")
if (!dir.exists(path_out)) {
  # Create the directory if it does not exist
  dir.create(path_out, showWarnings = TRUE, recursive = TRUE)
}

# Data Processing ------

## Calculate CIs using SE ----
df_full_models <- df_full_models |>
                    mutate(conf.low.se = estimate - 1.96*std.error, conf.high.se = estimate + 1.96*std.error) 

head(df_full_models)

## Select relevant rows ----
nrow(df_full_models)
df_full_models <- df_full_models |>  filter(str_detect(exposure, "abs") * str_detect(exposure, "30") | 
                                            str_detect(exposure, "rolling") * str_detect(exposure, "95"))
nrow(df_full_models)
# View(df_full_models)
unique(df_full_models$exposure)

## Create Labels ----
### For duration
# labels_duration_hd <- rep("Extreme heat day", 2)
label_duration <- c("Extreme heat day", "Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
label_duration_rep <- rep(label_duration, 2)


## Add labels to the dataframe ----
df_full_models$duration_label <- label_duration_rep
# df_full_models$threshold_label <- labels_threshold_comb
head(df_full_models)

## Set order of duration variable ----
## Order the levels of the Contrast variable
ord_duration <- c("Extreme heat day", "Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
df_full_models$duration_label <- factor(df_full_models$duration_label, levels=ord_duration)
df_full_models$duration_label <- fct_reorder(df_full_models$duration_label, desc(df_full_models$duration_label))


# Remove 2 day and 4 day heatwave from the plot
df_full_models <- df_full_models |> filter(!str_detect(duration_label, "2 days")) |> filter(!str_detect(duration_label, "4 days"))
head(df_full_models)
# Plot and save ----

## Absolute temp 30 ----
df_full_models_30 <- df_full_models |> filter(str_detect(exposure, "30"))
plot_30 <- func_plot_full_model(df_full_models_30, title = expression("UTCI >= 30" * degree * "C"))
ggsave(here(path_out, "plot_30.jpeg"), plot_30, width = 8, height = 10, dpi = 600)

## For percentile - 95 ----
df_full_models_95 <- df_full_models |> filter(str_detect(exposure, "95"))
head(df_full_models_95)
plot_95 <- func_plot_full_model(df_full_models_95, title = expression("UTCI >= 95th percentile"))

ggsave(here(path_out, "plot_95.jpeg"), plot_95, width = 8, height = 10, dpi = 600)

# Combine the plots ----
plot_combined <- plot_30 + plot_95
# Add tags to the plots
plot_combined <- plot_combined + plot_annotation(tag_levels = "A")
ggsave(here(path_out, "plot_combined.jpeg"), plot_combined, width = 12, height = 8, dpi = 600)
