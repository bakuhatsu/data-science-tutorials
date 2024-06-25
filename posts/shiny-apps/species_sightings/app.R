###############################################################################
# Sven Nelson                                                                 #
# 6/24/2024                                                                   #
# Shiny app for plotting species occurrence from GBIF.                        #
###############################################################################

#### Imports ####
require(shiny)
require(tidygeocoder)
require(memoise)

source("../R/plot_sightings.R")
source("../R/add_polygon_col.R")

#### Setup ####
# Set up a dataframe to use connecting names with species
specs <- tibble::tribble(
  ~name,                        ~species,                 ~short_name,    ~clr,
  "Monarch Butterfly",          "Danaus plexippus",       "Monarch",      "cyan",
  "Northern Cardinal",          "Cardinalis cardinalis",  "Cardinal",     "red",
  "Ruby Throated Hummingbird",  "Archilochus colubris",   "Hummingbird",  "pink",
  "White-Throated Sparrow",     "Zonotrichia albicollis", "Sparrow",      "yellow"
)

# Create the table of possible cities to check
locs <- tibble::tribble(
  ~name,            ~address,
  "Evansville",     "Evansville, IN",
  "West Lafayette", "West Lafayette, IN 47907", 
  "Davis",          "Davis, CA",
  "Seattle",        "Seattle, WA",
  "New Jersey",     "New Jersey, NY",
  "Miami",          "Miami, FL",
  "LA",             "Los Angelos, CA"
)
# Variable to keep track of whether data needs to be reloaded
reload_data <- TRUE
if (file.exists("locs.rds")) {
  locs2 <- readRDS("locs.rds")
  
  if (dplyr::all_equal(locs, locs2[,1:2]) & ncol(locs2) == 5) {
    locs <- locs2
    reload_data <- FALSE
  }
} 

if (reload_data) {
  # Get latitude and longitude
  locs <- geocode(locs, address, method = "osm", lat = latitude, long = longitude)
  
  # Populate a column in the data frame with the POLYGON call for each location
  locs <- add_polygon_col(locs)
  saveRDS(locs, file = "locs.rds")
}

#### User Interface ####
# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Organism migration tracking"),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("spec_pick", "Organism", choices = specs$name),
      selectInput("loc_pick", "Location", choices = locs$name)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("sightingsPlot", width = 400, height = 200) # Set size here
    )
  )
)

#### Server function ####
# Define server logic required to draw a histogram
server <- function(input, output) {

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

#### Run app ####
shinyApp(ui = ui, server = server)
