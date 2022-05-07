#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
#'

app_server <- function(input, output, session) {
  mod_sliderText_server("sliderText_1")

  #callModule(sliderText,"slide_two")
  #callModule(sliderText,"slide_three")
  #callModule(sliderText,"slide_four")
}
