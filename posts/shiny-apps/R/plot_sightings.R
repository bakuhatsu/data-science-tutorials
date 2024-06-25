###############################################################################
# Sven Nelson                                                                 #
# 6/24/2024                                                                   #
# Function for plotting species occurrence from GBIF.                         #
###############################################################################

plot_sightings <- function(species = "Danaus plexippus", location = wkt, title = "Monarchs in Evansville") {
  require(rgbif)
  require(tidyverse)
  
  # Get species taxonKey
  spec_id <- name_backbone(species)$usageKey
  
  # Get data from rgbif for the passed species at the passed location
  sightings <- occ_count(facet=c("month"), taxonKey=spec_id, geometry=location)
  
  library(tidyverse)
  # Make month columns into integers
  sightings$month <- as.numeric(sightings$month)
  # Fill in missing months with 0 values
  for (i in 1:12) {
    if (!(i %in% sightings$month)) {
      sightings <- add_row(sightings, month = i, count = 0)
    }
  }
  
  # Order rows by month
  sightings <- arrange(sightings, month)
  
  # Make column with text month names
  sightings <- mutate(sightings, Month = month.abb[month])
  
  # Make Month column factors
  sightings$Month <- factor(sightings$Month, levels = sightings$Month)
  
  # Plot the data as a barplot with occurrences for each month
  plt <- ggplot(sightings, aes(x = Month, y = count)) + # , fill = count
    geom_bar(stat="identity", color="black", fill = "cyan") + 
    xlab("Time of year") + 
    ylab("Occurrences") + 
    ggtitle(title) +
    theme_bw() + 
    theme(panel.border = element_blank(), panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
  
  return(plt)
}