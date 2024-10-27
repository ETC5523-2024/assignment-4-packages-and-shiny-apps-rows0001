# UI part
ui <- fluidPage(
  titlePanel("UFO Sightings Data Exploration"),

  tags$head(
    tags$style(HTML("
      body {
        background-color: #e9ecef;
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
      .shiny-input-container {
        margin-bottom: 15px;
      }
    "))
  ),

  sidebarLayout(
    sidebarPanel(
      selectInput("shape", "Select UFO Shape:", choices = unique(ufo_sightings$shape), selected = unique(ufo_sightings$shape)[1]),
      sliderInput("year", "Year:",
                  min = min_year,
                  max = max_year,
                  value = c(min_year, max_year),
                  step = 1),
      actionButton("update", "Update"),  # This button will be used to refresh data

      helpText("Select the shape of the UFO sightings and the year range to explore.")
    ),

    mainPanel(
      h2("UFO Sightings Plot"),
      plotOutput("sightingsPlot"),
      h3("Data Table"),
      tableOutput("sightingsTable"),
      h4("Interpretation Guide"),
      helpText("The bar chart represents the count of UFO sightings per year for the selected shape. The table below lists the details of sightings in the selected range.")
    )
  )
)

# Server part
server <- function(input, output) {
  # Reactive expression to filter data based on input
  filtered_data <- reactive({
    req(input$update)  # This will ensure the app only reacts after clicking the button
    ufo_sightings %>%
      filter(shape == input$shape,
             year >= input$year[1],
             year <= input$year[2])
  })

  # Plot output
  output$sightingsPlot <- renderPlot({
    req(filtered_data())  # Ensure there's filtered data to plot
    ggplot(filtered_data(), aes(x = year)) +
      geom_bar() +
      labs(title = paste("UFO Sightings of Shape:", input$shape),
           x = "Year",
           y = "Count")
  })

  # Table output
  output$sightingsTable <- renderTable({
    req(filtered_data())  # Ensure there's filtered data for the table
    filtered_data()
  })
}

# Run the application
shinyApp(ui = ui, server = server)

