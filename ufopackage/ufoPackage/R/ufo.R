# Load necessary libraries
library(tidyverse)
library(here)
library(withr)

# Download and read the data
url <- "https://github.com/jonthegeek/apis/raw/main/data/data_ufo_reports_with_day_part.rds"
ufo_path <- withr::local_tempfile(fileext = ".rds")
download.file(url, ufo_path)
ufo_data_original <- readRDS(ufo_path)

# Clean the data
ufo_sightings <- ufo_data_original |>
  dplyr::select(
    reported_date_time:city,
    state,
    country_code,
    shape:has_images,
    day_part
  ) |>
  dplyr::mutate(
    shape = tolower(shape)
  )

places <- ufo_data_original |>
  dplyr::select(
    city:country_code,
    latitude:elevation_m
  ) |>
  dplyr::distinct()

# Save cleaned data
save(ufo_sightings, file = "data-raw/ufo_sightings.RData")
save(places, file = "data-raw/places.RData")
