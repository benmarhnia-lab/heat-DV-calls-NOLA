# Load packages ----
library(tigris)
library(tidyverse)
library(raster)
library(ncdf4)
library(sf)
library(data.table)
library(fst)

# Read data ---- 
## NOLA zip code shape file

### Get the bbox for the orleans parish
# orleans_parish_shp <- st_read("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/raw-data-extracted/Orleans_Parish_shp/Orleans_Parish.shp")
# bounding_box <- st_bbox(orleans_parish_shp)

### Get list of Zip codes used in the NOPD-DV dataset ----- 
df_nopd_dv_cases <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/dv_cases.fst", 
                              as.data.table = TRUE)
df_valid_zips <- df_nopd_dv_cases[(!is.na(Zip) & Zip != "None" & Zip != ""),]
zips_nopd_dv <- unique(df_valid_zips$Zip)

### Get the shape file of zip codes using tigris
# zctas_nola <- zctas(filter_by = bounding_box)
zctas_nola <- zctas(starts_with = c("70"))
# sort(unique(zctas_nola$ZCTA5CE20))
zctas_nola_short <- zctas_nola |> 
                        filter(ZCTA5CE20 %in% zips_nopd_dv) |>
                        mutate(Zip = ZCTA5CE20)

# sort(unique(zctas_nola_short$Zip))

### Convert CRS
zctas_nola_wgs84 <- st_transform(zctas_nola_short, crs = 4326)

### Get the centroid
centroids <- st_centroid(zctas_nola_wgs84)

### Extract latitude and longitude
coords <- st_coordinates(centroids)
lat_long <- data.frame(latitude = coords[,2], longitude = coords[,1])

# Combine ZIP code data with lat-long
zip_data_spdf <- data.frame(zctas_nola_wgs84, lat_long)
# Convert to SpatialPointsDataFrame
coordinates(zip_data_spdf) <- ~longitude+latitude

### Create a plot to viz
# ggplot(data = zctas_nola) + 
#   geom_sf() + 
#   theme_minimal() +
#   labs(title = "ZIP Code Tabulation Areas in Louisiana")


## Read temperature data
setwd("C:/DATA/data_hub/gridMET/daily-data-US/t-max/")
a <- list.files(pattern ="\\.nc")

# Initialize empty list
df_list <- list()

for (i in a) {
        
        # Read the files as raster brick
        rd0 <- brick(i)
        ext <- extent(rd0)
        
        # Check if raster needs rotation and rotate if necessary
        if (ext@xmin >= 0 & ext@xmax > 180) {
                rd1 <- rotate(rd0)
        } else {
                rd1 <- rd0
        }

        ## Restrict the spatial data to the region boundary 
        cd0 <- crop(x = rd1, y = zctas_nola_wgs84)
        cd1 <- rasterize(x = zctas_nola_wgs84, y = cd0)
        cd2 <- mask(x = cd0, mask = cd1)

        # Extract the climate data for each PSU location
        df1 <- raster::extract(cd2,   # raster layer cropped to the country boundary
        zip_data_spdf,      # SPDF with centroids for buffer
        df=TRUE)    # return a dataframe

        # Add the PSU information
        df1 <- setDT(cbind(zip_data_spdf@data, df1))
        
        df2 <- melt(df1, id.vars = c("Zip"), measure = patterns("^X"), 
        variable.name = "date", value.name = "tmax")
        head(df2)
        df2[, date := as.numeric(substring(date, 2))]
        df2[, date := as.Date(date, origin = "1900-01-01")][!is.na(tmax)]

        # Add the data frame to the list
        df_list[[i]] <- df2
        print(paste("finished processing", i))
}

df_temp_data_nola <- rbindlist(df_list)

# Add year, month and weekday ----
df_temp_data_nola <- df_temp_data_nola[, ':=' ( 
                                        year = lubridate::year(date),
                                        month = lubridate::month(date),
                                        weekday = lubridate::wday(date, label = TRUE))]

# Convert temperature to celcius ----
df_temp_data_nola[, tmax_cel := tmax - 273.15]
# df_temp_data_nola |> janitor::tabyl(year)

# Identify zip codes with missing data ----
df_temp_data_nola[which(is.na(tmax)),] |> 
        janitor::tabyl(Zip) |> 
        arrange(desc(n))

# Save file
write_fst(df_temp_data_nola, "D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/2.1_nola_temp_zip_code.fst")
