# load libraries ----
rm(list = ls())
pacman::p_load(tidyverse, janitor, data.table, fst, here, sf, tigris, viridis)

# set paths ----
source("paths-mac.R")

# Read data ----
df_nopd_dv_cases <- read_fst(here(path_project, "processed-data", "1.3-nopd-calls-raw-dv-only-completed.fst"))
glimpse(df_nopd_dv_cases)

# create dataframe for plots ----
df_plot <- df_nopd_dv_cases |>
    group_by(Zip, year) |>
      summarize(DV_total = n()) |>
    filter(DV_total > 50) |>
    group_by(Zip) |>
      summarise(avg_cases_all = mean(DV_total, na.rm = TRUE)) |>
    mutate(avg_cases_all_scaled = avg_cases_all / 1000)

head(df_plot |> arrange(avg_cases_all))
head(df_plot |> arrange(desc(avg_cases_all)))


# plot the maps ----
min(df_plot$Zip)
vec_zips <- unique(df_plot$Zip)
sort(vec_zips)

nola_zips <- zctas(starts_with = c("701"), cb = TRUE, year = 2020) 
# plot(nola_zips[1])

# Join the spatial data with your cases data
nola_map <- nola_zips |>
  inner_join(df_plot, by = c("ZCTA5CE20" = "Zip")) 
  # filter(ZCTA5CE20 != 70510 & ZCTA5CE20 != 70525) 

sort(unique(nola_map$ZCTA5CE20))

## Create the choropleth map
plot_dv <- ggplot(nola_map) +
  geom_sf(aes(fill = avg_cases_all_scaled), color = "white") +
  scale_fill_viridis(name = "Avg. number of cases per year bw 2011 and 2021",
                     option = "plasma",
                     direction = -1) +
  # print the ZCTA5CE20 column
  # geom_sf_text(aes(label = ZCTA5CE20), size = 3, color = "black") +
  theme_minimal() +
   coord_sf(xlim = c(-90.2, -89.6),
           ylim = c(29.8, 30.2)) +
  labs(title = "",
       subtitle = "",
       caption = "Data source: NOPD call for services") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    legend.position = "bottom"
  )

## Save the plot
ggsave(here(path_project, "outputs", "figures", "dv_cases_map.png"), 
  plot_dv, width = 10, height = 10, dpi = 300,
  bg = "white")
