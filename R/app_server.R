#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
#'
library(tidyverse)

app_server <- function(input, output, session) {
  # add the data to plot inside the renderplot function
  output$static <- renderPlot(
    # create a plot
    ggplot(data = mtcars,
           mapping = aes(x = wt, y = mpg)) +
      geom_point(colour='darkblue', size = 4, alpha = 0.5)+
      theme_classic(),

    # set the  height, width and resolution.
    width = "auto",
    height = "auto",
    res = 96)

  output$notstatic <- renderPlot(
    # create a plot
    ggplot(data = mtcars,
           mapping = aes(x = wt, y = mpg)) +
      geom_point(colour='darkblue', size = 4, alpha = 0.5)+
      theme_classic(),

    # set the  height, width and resolution.
    width = "auto",
    height = "auto",
    res = 96)

  mod_sliderText_server("sliderText_1")

  #callModule(sliderText,"slide_two")
  #callModule(sliderText,"slide_three")
  #callModule(sliderText,"slide_four")
}
