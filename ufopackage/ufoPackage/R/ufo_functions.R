#' Summarize UFO Sightings by Shape
#'
#' This function takes a dataset of UFO sightings and returns a summary
#' of sightings by shape.
#'
#' @param data A data frame of UFO sightings.
#' @return A data frame summarizing the number of sightings per shape.
#' @export
summarize_sightings_by_shape <- function(data) {
  data %>%
    group_by(shape) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(desc(count))
}

#' Filter UFO Sightings by Year
#'
#' This function filters the UFO sightings data for a specified year.
#'
#' @param data A data frame of UFO sightings.
#' @param year A numeric value indicating the year to filter by.
#' @return A filtered data frame with sightings from the specified year.
#' @export
filter_sightings_by_year <- function(data, year) {
  data %>%
    filter(format(as.POSIXct(reported_date_time, format = "%Y-%m-%d %H:%M:%S"), "%Y") == year)
}

#' Count Sightings by Month
#'
#' This function counts the number of UFO sightings by month.
#'
#' @param data A data frame of UFO sightings.
#' @return A data frame summarizing the number of sightings per month.
#' @export
count_sightings_by_month <- function(data) {
  data %>%
    group_by(month) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(as.numeric(month))
}

#' Count Sightings by Day of Week
#'
#' This function counts the number of UFO sightings by day of the week.
#'
#' @param data A data frame of UFO sightings.
#' @return A data frame summarizing the number of sightings per day of the week.
#' @export
count_sightings_by_day <- function(data) {
  data %>%
    group_by(day_of_week) %>%
    summarise(count = n(), .groups = 'drop') %>%
    arrange(factor(day_of_week, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")))
}

#' Plot UFO Sightings Over Time
#'
#' This function creates a line plot of UFO sightings over the years.
#'
#' @param data A data frame of yearly UFO sightings counts.
#' @return A ggplot object showing UFO sightings over time.
#' @export
plot_sightings_over_time <- function(data) {
  data %>%
    ggplot(aes(x = year, y = count)) +
    geom_line() +
    labs(title = "UFO Sightings Over Time", x = "Year", y = "Number of Sightings") +
    theme_minimal()
}

#' Plot Sightings by Shape
#'
#' This function creates a bar plot of UFO sightings by shape.
#'
#' @param data A data frame of UFO sightings.
#' @return A ggplot object showing UFO sightings by shape.
#' @export
plot_sightings_by_shape <- function(data) {
  shape_counts <- summarize_sightings_by_shape(data)
  ggplot(shape_counts, aes(x = reorder(shape, -count), y = count)) +
    geom_bar(stat = "identity") +
    labs(title = "UFO Sightings by Shape", x = "Shape", y = "Number of Sightings") +
    theme_minimal() +
    coord_flip() # Flipping coordinates for better visibility
}
