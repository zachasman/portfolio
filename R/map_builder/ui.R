library(shiny)

load("./dataset.RData")
load("dataset.RData")

ui <- fluidPage(
  fluidRow(
    column("Silver State",
           width = 10, offset = 1,
           tags$h3("Select Area"),
           panel(
             selectizeInput('counties', label = 'County', multiple = TRUE, c(unique(sort(county$County)))),
             selectizeInput('cds', label = 'Congressional District', multiple = TRUE, c(unique(sort(cong_district$`Congressional District`)))),
             selectizeInput('regions', label = 'Region', multiple = TRUE, c(unique(sort(region$Region)))),
             uiOutput("turf"),
             uiOutput("precinct"),
             selectInput("metric", label = 'Select Metric', choices = metrics_list, selected = "Delegates"),
             checkboxInput("allPrecincts", "See All Precincts", FALSE)
           ),
           leafletOutput(outputId = "map", height = "600")
    )
  )
)
