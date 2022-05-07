#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd

library(shinyMobile)
library(Twenty)

source("R/01_load.R")


app_ui <- function(request) {
    # Leave this function for adding external resources
    golem_add_external_resources()
    # Your application UI logic with commas afterwards
    fluidPage(
      h1("West Data"),

      h2("ShinyTwenty"),
      tagList(

        h2("PLOT A"),
        # create a static plot
        plotOutput("static"),

        h2("PLOT B"),
        plotOutput("notstatic")

      # Sliders from the module as many times as you want with different names.
      #mod_sliderText_ui("sliderText_1"),
      #mod_sliderText_ui("sliderText_2"),
      #mod_sliderText_ui("sliderText_3"),
      #mod_sliderText_ui("sliderText_4")

      # Create four sliders without so much code.
      #sliderTextUI("slide_one"),
      #sliderTextUI("slide_two"),
      #sliderTextUI("slide_three"),
      #sliderTextUI("slide_four")

    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "ShinyTwenty"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
