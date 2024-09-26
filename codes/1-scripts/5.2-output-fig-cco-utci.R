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
dim(df_full_models)

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
df_full_models <- df_full_models |>  filter(str_detect(exposure, "rolling") * str_detect(exposure, "85") | 
                                           str_detect(exposure, "rolling") * str_detect(exposure, "90") | 
                                            str_detect(exposure, "rolling") * str_detect(exposure, "95"))
nrow(df_full_models)
# View(df_full_models)
unique(df_full_models$exposure)

## Create Labels ----
### For duration
labels_duration_hd <- rep("Extreme heat day", 3)
label_duration <- c("Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
label_duration_rep <- rep(label_duration, 3)

# ### For thresholds
# labels_threshold_abs <- c("Tmax >= 30°C", "Tmax >= 30°C", "Tmax >= 30°C")
# labels_threshold_abs <- rep(labels_threshold_abs, 5)

# labels_threshold_perc_single <- c("Tmax > 85th Percentile", "Tmax > 90th Percentile", "Tmax > 95th Percentile")
# labels_threshold_perc_multi <- rep(labels_threshold_perc_single, each = 4)
# labels_threshold_perc <- c(labels_threshold_perc_single, labels_threshold_perc_multi)

# #### combine these labels and repeat the label 4 times
# labels_threshold_comb <- c(labels_threshold_abs, labels_threshold_perc)
# length(labels_threshold_comb)
# # labels_threshold_comb_all_dep_vars <- rep(labels_threshold_comb, 3)

## Add labels to the dataframe ----
df_full_models$duration_label <- c(labels_duration_hd, label_duration_rep)
# df_full_models$threshold_label <- labels_threshold_comb
# View(df_full_models)

## Set order of duration variable ----
## Order the levels of the Contrast variable
ord_duration <- c("Extreme heat day", "Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
df_full_models$duration_label <- factor(df_full_models$duration_label, levels=ord_duration)
df_full_models$duration_label <- fct_reorder(df_full_models$duration_label, desc(df_full_models$duration_label))


# Remove 2 day heatwave from the plot
df_full_models <- df_full_models |> filter(!str_detect(duration_label, "2 days"))

# Plot and save ----

## For percentile - 85 ----
df_full_models_85 <- df_full_models |> filter(str_detect(exposure, "85"))
nrow(df_full_models_85)
head(df_full_models_85)

plot_85 <- func_plot_full_model(df_full_models_85, title = "UTCI >= 85th Percentile")
ggsave(here(path_out, "plot_85.jpeg"), plot_85, width = 8, height = 10, dpi = 600)

## For percentile - 90 ----
df_full_models_90 <- df_full_models |> filter(str_detect(exposure, "90"))
plot_90 <- func_plot_full_model(df_full_models_90, title = "UTCI >= 90th Percentile")
ggsave(here(path_out, "plot_90.jpeg"), plot_90, width = 8, height = 10, dpi = 600)

## For percentile - 95 ----
df_full_models_95 <- df_full_models |> filter(str_detect(exposure, "95"))
plot_95 <- func_plot_full_model(df_full_models_95, title = "UTCI >= 95th Percentile")
ggsave(here(path_out, "plot_95.jpeg"), plot_95, width = 8, height = 10, dpi = 600)
