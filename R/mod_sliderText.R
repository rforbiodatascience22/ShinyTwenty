#' sliderText UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#'
mod_sliderText_ui <- function(id){
  ns <- NS(id)
  # make a list of tags.
  tagList(
    # create a slider that goes from 0 to 100.
    sliderInput(ns("slider"), "Slide Me", 0,100,1),
    # Show a number underneath the slider to say which number the slider shows.
    textOutput(ns("number"))
  )
}

#' @noRd
#' sliderText Server Functions
#' create a function for rendering the module user interface above
sliderText <- function(input, output, session){
  output$number <- renderText(input$slider)
}

mod_sliderText_server <- function(id){
    # Your application server logic (no commas afterwards)

    # call the id from the slider user interface.
    callModule(sliderText,"slide_one")
}
