###############################################################################
# Sven Nelson                                                                 #
# 6/24/2024                                                                   #
# Shiny app module for plotting species occurrence from GBIF.                 #
###############################################################################

#### User Interface ####
# Define UI for application that draws a histogram
sightingsInput <- function(id, label = "Sightings", specs, locs, sel = "Monarch Butterfly") {
  ns <- NS(id)
  tagList(
    h4(label),
    selectInput(ns("spec_pick"), "Organism", choices = specs$name, selected = sel),
    selectInput(ns("loc_pick"), "Location", choices = locs$name)
  )
}

sightingsOutput <- function(id, label = "Sightings") {
  ns <- NS(id)
  tagList(
    plotOutput(ns("sightingsPlot"), width = 400, height = 200)
  )
}

#### Server function ####
# Define server logic required to draw a histogram
sightingsServer <- function(id, specs, locs) {
  moduleServer(
    id,
    function(input, output, session) {
      output$sightingsPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        sp_nm <- input$spec_pick
        lc_nm <- input$loc_pick
        sp <- specs[specs$name == sp_nm,]$species
        sp_col <- specs[specs$name == sp_nm,]$clr
        lc <- locs[locs$name == lc_nm,]$polygon
        
        plot_sightings(species = sp, location = lc, paste0(sp_nm, " in ", lc_nm)) + 
          geom_bar(stat="identity", color="black", fill = sp_col)
      })
    }
  )
}

