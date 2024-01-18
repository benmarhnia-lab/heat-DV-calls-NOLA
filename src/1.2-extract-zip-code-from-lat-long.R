# Load packages ----
library(tidyverse)
library(fst)
library(janitor)
library(ggmap)
library(zipcodeR)


## Separate Lat and Long
### Split the 'location' column into 'lat' and 'long'
df_missing_zip$Location_new <- gsub("[()]", "", df_missing_zip$Location)  # Remove parentheses
coordinates <- strsplit(df_missing_zip$Location_new, ", ")  # Split by comma and space

### Create 'lat' and 'long' columns
df_missing_zip$lat <- as.numeric(sapply(coordinates, function(x) x[1]))
df_missing_zip$long <- as.numeric(sapply(coordinates, function(x) x[2]))

## Number of cases where lat long is not usable
df_latlong_unusable <- df_missing_zip |>
    filter(long > -89.7891)
nrow(df_latlong_unusable)

## Number of cases where lat long is usable
df_latlong_usable <- df_missing_zip |>
    filter(!uid %in% df_latlong_unusable$uid)

## Check
nrow(df_latlong_unusable) + nrow(df_latlong_usable) == nrow(df_missing_zip)


# Read data
df_latlong_usable <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_zip_missing_w_latlong.fst")
head(df_latlong_usable)

# Set up Google Maps API
# register_google(key = "AIzaSyAqO9vigcrdTSBEuPnMJPMKToBInQbrH08", write = TRUE)

# Convert lat and long to zip code

# Create an empty vector to store zip codes
zip_codes <- character(nrow(df_latlong_usable))

# Loop through the rows and find zip codes
for (i in 1:nrow(df_latlong_usable)) {
  result <- revgeocode(c(df_latlong_usable$long[i], df_latlong_usable$lat[i]), output = "address")
  if (!is.null(result)) {
    # Extract the zip code from the address
    zip_code <- sub('.*, ([0-9]{5}),.*', '\\1', result)
    zip_codes[i] <- zip_code
  } else {
    zip_codes[i] <- NA
  }
}

# Add the zip code column to the data frame
df_latlong_usable$zip_code <- zip_codes

install.packages("zipcodeR")
