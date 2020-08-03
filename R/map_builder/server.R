library(mapview)
library(leaflet)
library(sf)
library(dplyr) 
library(DT)
library(shiny)
library(shinyWidgets)
library(RColorBrewer)
library(highcharter)

# load("./dataset.RData")
# load("dataset.RData")

server <- function(input, output, session) {
  
  output$turf <- renderUI({
    selectizeInput("turfs", "Turf", multiple = TRUE, c(unique(sort(region_turf$Turf[region_turf$Region == input$regions]))))
  })
  
  output$precinct <- renderUI({
    selectizeInput("precincts", "Precinct", multiple = TRUE, c(unique(sort(region_turf_precinct$Precinct[region_turf_precinct$Turf == input$turfs]))))
  })
  
  map_data <- reactive({
    
    if(!is.null(input$regions) 
       & is.null(input$turfs) 
       & is.null(input$precincts) 
       & (is.null(input$counties) | !is.null(input$counties)) 
       & (is.null(input$cds) | !is.null(input$cds)))
      res <- region_turf %>% filter(Region %in% input$regions)
    else 
      if(!is.null(input$turfs) 
         & is.null(input$precincts) 
         & (is.null(input$counties) | !is.null(input$counties))
         & (is.null(input$cds) | !is.null(input$cds))
         & input$allPrecincts == FALSE)
        res <- region_turf_precinct %>% filter(Turf %in% input$turfs) 
      else
        if(!is.null(input$precincts) 
           & (is.null(input$counties) | !is.null(input$counties)) 
           & (is.null(input$cds) | !is.null(input$cds))
           & input$allPrecincts == FALSE)
          res <- region_turf_precinct %>% filter(Precinct %in% input$precincts)
        else 
          if(is.null(input$regions) 
             & is.null(input$turfs) 
             & is.null(input$precincts) 
             & is.null(input$counties) 
             & is.null(input$cds)
             & input$allPrecincts == FALSE)
            res <- region %>% group_by(Region)
          else 
            if(!is.null(input$counties) 
               & is.null(input$regions)
               & is.null(input$turfs) 
               & is.null(input$precincts) 
               & is.null(input$cds)
               & input$allPrecincts == FALSE)
              res <- county %>% filter(County %in% input$counties)
            else 
              if(!is.null(input$cds)  
                 & is.null(input$regions) 
                 & is.null(input$turfs) 
                 & is.null(input$precincts)
                 & is.null(input$counties)
                 & input$allPrecincts == FALSE)
                res <- cong_district %>% filter(`Congressional District` %in% input$cds)
              else
                if(!is.null(input$cds)  
                   & is.null(input$regions) 
                   & is.null(input$turfs) 
                   & is.null(input$precincts) 
                   & !is.null(input$counties)
                   & input$allPrecincts == FALSE)
                  res <- cong_district %>% filter(`Congressional District` %in% input$cds)
                else
                  if(input$allPrecincts == TRUE 
                     & (is.null(input$regions) | !is.null(input$regions))
                     & (is.null(input$turfs) | !is.null(input$turfs))
                     & (is.null(input$precincts) | !is.null(input$precincts))
                     & (is.null(input$cds) | !is.null(input$cds))
                     & (is.null(input$counties) | !is.null(input$counties)))
                    res <- region_turf_precinct %>% filter(is.null(input$regions) | Region %in% input$regions,
                                                           is.null(input$turfs) | Turf %in% input$turfs,
                                                           is.null(input$precincts) | Precinct %in% input$precincts)
                  
                  res
  })
  
  output$map <- renderLeaflet({
    req(input$metric)
    
    res <- map_data()
    
    map <- leaflet() %>%
      addProviderTiles(provider = "CartoDB.Positron",
                       providerTileOptions(detectRetina = FALSE,
                                           reuseTiles = TRUE,
                                           minZoom = 4,
                                           maxZoom = 8)) 
    
    
    map %>% draw_demographics(input, res)
    
  })
  
  getpal <- function(cpop,nmax){
    if (length(cpop)>1){
      # try out value from nmax down to 1
      for (n in nmax:1){
        qpct <- 0:n/n
        cpopcuts <- quantile(cpop,qpct)
        # here we test to see if all the cuts are unique
        if (length(unique(cpopcuts))==length(cpopcuts)){
          if (n==1){ 
            # The data is very very skewed.
            # using quantiles will make everything one color in this case (bug?)
            # so fall back to colorBin method
            return(colorBin("YlOrRd",cpop, bins=nmax))
          }
          return(colorQuantile("YlOrRd", cpop, probs=qpct))
        }
      }
    }
    # if all values and methods fail make everything white
    pal <- function(x) { return("white") }
  }
  
  draw_demographics <- function(map, input, data) {
    
    cpop <- data[[input$metric]]
    
    if (length(cpop)==0) return(map) # no pop data so just return (much faster)
    
    pal <- getpal(cpop,7)
    
    map %>%
      clearShapes() %>%
      addPolygons(data = data,
                  fillColor = ~pal(cpop),
                  fillOpacity = 1,
                  color = "#BDBDC3",
                  weight = 3, popup = data$cpop) 
  }
  
}
