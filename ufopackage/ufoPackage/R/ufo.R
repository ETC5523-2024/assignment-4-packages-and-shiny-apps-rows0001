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


# Check for missing values
missing_values <- ufo_sightings %>%
  summarise(across(everything(), ~ sum(is.na(.))))
print(missing_values)

# Optionally, you can filter out rows with missing values in critical columns
ufo_sightings <- ufo_sightings %>%
  filter(!is.na(reported_date_time) & !is.na(city) & !is.na(state))

# Extract month and day of the week
ufo_sightings <- ufo_sightings %>%
  mutate(
    month = format(as.POSIXct(reported_date_time, format = "%Y-%m-%d %H:%M:%S"), "%m"),
    day_of_week = weekdays(as.POSIXct(reported_date_time, format = "%Y-%m-%d %H:%M:%S"))
  )


ufo_sightings <- ufo_sightings %>%
  mutate(
    state = as.factor(state),
    shape = as.factor(shape),
    day_part = as.factor(day_part)
  )

# Count sightings by shape
shape_counts <- ufo_sightings %>%
  group_by(shape) %>%
  summarise(count = n(), .groups = 'drop') %>%
  arrange(desc(count))


# Save cleaned data
save(ufo_sightings, file = "data-raw/ufo_sightings.RData")
save(places, file = "data-raw/places.RData")
