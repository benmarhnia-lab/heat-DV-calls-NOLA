rm(list =ls())
options(scipen=999)
options(digits=5)
pacman::p_load(tidyverse, ggpubr, ggplot2, sjPlot, readxl, here, extrafont, ggbreak, patchwork)


# font_import() # run only once
# loadfonts(device="win") # run only once

# Load data ----
here_output_files <- here("outputs", "models", "models-cco-wbgt")
df_full_models <- read.csv(here(here_output_files, "models_consolidated_cco_wbgt.csv"))
dim(df_full_models)

# Constants ---------------
## Call the function to plot ----
source(here("src", "8.5-function-to-plot-models-and-effect-modifiers.R"))
## Path for outputs ----
path_out <- here("outputs", "figures", "cco-wbgt")
!dir.exists(path_out) && dir.create(path_out, recursive = TRUE)

unique(df_full_models$exposure)
nrow(df_full_models)

# Data Processing ------

## Calculate CIs using SE ----
df_full_models <- df_full_models |>
                    mutate(conf.low.se = estimate - 1.96*std.error, conf.high.se = estimate + 1.96*std.error) 

head(df_full_models)

## Select relevant rows ----
nrow(df_full_models)
df_full_models <- df_full_models |>  filter(str_detect(exposure, "rolling") * str_detect(exposure, "95") | 
                                           str_detect(exposure, "abs") * str_detect(exposure, "24"))
nrow(df_full_models)
# View(df_full_models)
unique(df_full_models$exposure)

## Create Labels ----
### For duration
labels_duration_hd <- rep("Extreme heat day", 3)
label_duration <- c("Extreme heat day", "Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
label_duration_rep <- rep(label_duration, 2)

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
df_full_models$duration_label <- label_duration_rep
# df_full_models$threshold_label <- labels_threshold_comb
# View(df_full_models)

## Set order of duration variable ----
## Order the levels of the Contrast variable
ord_duration <- c("Extreme heat day", "Heatwave: 2 days", "Heatwave: 3 days", "Heatwave: 4 days", "Heatwave: 5 days")
df_full_models$duration_label <- factor(df_full_models$duration_label, levels=ord_duration)
df_full_models$duration_label <- fct_reorder(df_full_models$duration_label, desc(df_full_models$duration_label))


# Plot and save ----

## For absolute ----
df_full_models_abs <- df_full_models |> filter(str_detect(exposure, "abs"))
nrow(df_full_models_abs)
# head(df_full_models_abs)

plot_abs <- func_plot_full_model(df_full_models_abs, title = "WBGT >= 24 °C")
ggsave(here(path_out, "plot_abs.jpeg"), plot_abs, width = 6, height = 6, dpi = 600)


## For percentile ----
df_full_models_perc <- df_full_models |> filter(str_detect(exposure, "rel"))
nrow(df_full_models_perc)
head(df_full_models_perc)

plot_perc <- func_plot_full_model(df_full_models_perc, title = "WBGT >= 95th Percentile")
ggsave(here(path_out, "plot_perc.jpeg"), plot_perc, width = 6, height = 6, dpi = 600)

