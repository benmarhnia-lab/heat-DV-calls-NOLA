# Load packages ----
library(tidyverse)
library(fst)
library(janitor)
library(ggmap)
library(zipcodeR)

# Read data
df_latlong_usable <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/nopd_calls_zip_missing_w_latlong.fst")
head(df_latlong_usable)

search_radius(30.15380, -89.855555, 5)
result <- revgeocode(c(-89.855555, 30.15380), output = "all")
result$results[[1]]$postal_code

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
