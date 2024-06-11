#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)
library(ggplot2)

# Define UI for app that draws a histogram ----
ui <- page_sidebar(
  sidebar = sidebar(open = "open",
                    selectInput(inputId = "select_year", label = "Select Year", choices = c(2007)),
                    selectInput(inputId = "sex", label = "Select Sex", choices = c("female", "male"))
  ),
  plotOutput("plot")
  # print("hello"),
  # print(df)
)

server <- function(input, output, session) {
  reactive_data <- reactive({
    df <- palmerpenguins::penguins
    # Summarize data
    sum_data <- Rmisc::summarySE(df, measurevar = "body_mass_g", groupvars = c("species", "year", "sex"), na.rm = TRUE)
    sum_data$sex <- as.character(sum_data$sex)
    # Filter data
    dplyr::filter(sum_data, year == input$select_year & sex == input$sex)
    
    # ggplot(new_data, aes(x = species, y= body_mass_g, fill = species)) +
    # geom_bar(stat="identity", color="black", position=position_dodge(), size = 0.5, width = 0.5) +
    # # Add error bars
    # geom_errorbar(aes(ymin=body_mass_g - se, ymax=body_mass_g + se), width=.1) +
    # theme_bw()
  })
  
  output$plot <- renderPlot({
    ggplot(reactive_data(), aes(x = species, y= body_mass_g, fill = species)) +
      geom_bar(stat="identity", color="black", position=position_dodge(), size = 0.5, width = 0.5) +
      #   # Add error bars
      geom_errorbar(aes(ymin=body_mass_g - se, ymax=body_mass_g + se), width=.1) +
      theme_bw()
    # reactive_data()
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
