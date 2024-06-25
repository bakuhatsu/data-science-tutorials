###############################################################################
# Sven Nelson                                                                 #
# 6/24/2024                                                                   #
# Function for generating a polygon with 4 corners for RGBIF                  #
###############################################################################

require(tidygeocoder)

# Function to return df with polygon column
add_polygon_col <- function(df) {
  # Create function to generate string with 4 corners for POLYGON call
  generate_polygon <- function(lat, long, d_lg=0.9, d_lt=0.37) {
    # Paste is not vectorize, use sprintf instead (limit decimals to 4 places)
    p = sprintf("POLYGON((%.4f %.4f, %.4f %.4f, %.4f %.4f, %.4f %.4f, %.4f %.4f))", 
                long-d_lg, lat+d_lt, 
                long-d_lg, lat-d_lt,
                long+d_lg, lat-d_lt,
                long+d_lg, lat+d_lt,
                long-d_lg, lat+d_lt
    )
    return(p)
  }
  # Populate a column in the data frame with the POLYGON call for each location
  df <- mutate(df, polygon = generate_polygon(df$latitude, df$longitude))
  return(df)
}