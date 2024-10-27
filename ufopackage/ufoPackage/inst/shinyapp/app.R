library(shiny)
library(plotly)
library(dplyr)
library(lubridate)
library(ufoPackage)

# Extract year
ufo_sightings$year <- year(ymd_hms(ufo_sightings$reported_date_time))

# Get min and max years
min_year <- min(ufo_sightings$year, na.rm = TRUE)
max_year <- max(ufo_sightings$year, na.rm = TRUE)

# UI part
ui <- fluidPage(
  titlePanel("UFO Sightings Data Exploration"),

  # Add custom CSS for styling
  tags$head(
    tags$style(HTML("
      body {
        background-color: #add8e6;  /* Pastel blue background color */
        font-family: Arial, sans-serif;
      }
      .panel {
        background-color: #fff;
        border-radius: 5px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
      }
      h2 {
        color: #007bff;
      }
      footer {
        margin-top: 30px;
        padding: 10px 0;
        text-align: center;
        color: #888;
        font-size: 0.9em;
      }
    "))
  ),

  sidebarLayout(
    sidebarPanel(
      selectInput("shape", "Select UFO Shape:", choices = unique(ufo_sightings$shape),
                  selected = unique(ufo_sightings$shape)[1], multiple = TRUE),
      helpText("Choose one or more UFO shapes to filter the sightings data. Available shapes include: 'disk', 'triangle', 'light', etc."),

      selectInput("state", "Select State:", choices = unique(ufo_sightings$state),
                  selected = unique(ufo_sightings$state)[1]),
      helpText("Select a state to view UFO sightings specific to that location. This helps narrow down your search to a particular area."),

      sliderInput("year", "Year:",
                  min = min_year,
                  max = max_year,
                  value = c(min_year, max_year),
                  step = 1),
      helpText("Adjust the year range to filter sightings within a specific time frame. For example, selecting 2010-2015 will show sightings that occurred between those years."),

      actionButton("update", "Update"),
      actionButton("about", "About"),

      helpText("Use the above filters to explore UFO sightings data. Once selections are made, click 'Update' to see the results.")
    ),

    mainPanel(
      h2("UFO Sightings Plot"),
      plotlyOutput("sightingsPlot"),
      h4("Interpretation Guide"),
      helpText("The plot displays the number of UFO sightings by year based on your selections. Each color represents a different UFO shape, allowing you to see trends over time. Hover over the bars for detailed counts of sightings in each year.")
    )
  ),

  # Footer with GitHub contact link
  tags$footer(
    HTML("
      <footer>
        <p>Contact the author on
          <a href='https://github.com/rows0001' target='_blank'>GitHub</a>.
        </p>
      </footer>
    ")
  )
)

# Server part
server <- function(input, output, session) {

  # Reactive filtered data
  filtered_data <- reactive({
    req(input$update)
    ufo_sightings %>%
      filter(shape %in% input$shape, state == input$state, year >= input$year[1], year <= input$year[2])
  })

  # Render plot with Plotly
  output$sightingsPlot <- renderPlotly({
    plot_data <- filtered_data() %>%
      group_by(year, shape) %>%
      summarise(count = n(), .groups = 'drop')

    plot_ly(plot_data, x = ~year, y = ~count, color = ~shape, type = 'bar') %>%
      layout(
        title = paste("UFO Sightings by Year for Shapes:", paste(input$shape, collapse = ", "),
                      "in State:", input$state),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Count of Sightings"),
        barmode = 'stack',
        margin = list(t = 60, r = 20, b = 60, l = 60)  # Adding margin around the plot
      ) %>%
      config(modeBarButtonsToRemove = c("pan2d", "lasso2d", "select2d"))  # Removing specific buttons
  })

  # Show modal dialog with About information
  observeEvent(input$about, {
    showModal(modalDialog(
      title = "About UFO Sightings Data Exploration",
      "This Shiny application allows users to explore UFO sightings data by selecting specific UFO shapes, states, and year ranges.
      Users can visualize the number of sightings by year for their selected filters.",
      easyClose = TRUE,
      footer = NULL
    ))
  })
}

# Run the app
shinyApp(ui = ui, server = server)
