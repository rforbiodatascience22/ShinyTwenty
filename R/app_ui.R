#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import Twenty
#' @import reactable
#' @import shiny
#' @import dplyr
#' @import tibble
#' @import stringr
#' @import ggplot2
#' @import ggrepel
#' @noRd
# devtools::install_github("rforbiodatascience22/Twenty")
# library(Twenty)
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(

      # Add a theme.
      theme = bslib::bs_theme(version = 4, bootswatch = "minty"),
      h1(" ShinyTwenty"),
      titlePanel("R for Bio Data Science 2022"),
      p(" Based on the Paper: Predicting the clinical status of human breast cancer by using gene expression profiles,
           by Mike West, Carrie Blanchette, Holly Dressman et al."),

      # output Text:create general text in the ui and display using the server.
      textOutput("text"),


      # upload a file:
      # fileInput(inputId = "upload", label = "Upload a file"),

      # input: create a slider.
      # sliderInput(inputId = "min", label = "Limit (minimum)", value = 50, min = 0, max = 100),

      #  input: create an input selection criteria
      # animals <- c("dog", "cat", "mouse", "bird", "other"),
      # selectInput(inputId = "trousers", label = "more_trousers", animals),

      # input:  Collect small amounts of text with text input.
      # textInput(inputId ="name", label = "Name: "),

      #  input: Collect more information
      # textAreaInput(inputId ="story",label =  "Write here what you know about this dataset. ", rows = 3),

      #  input: Collect numeric values
      # numericInput(inputId ="num", label = "Enter a number: ", value = 0, min = 0, max = 30),

      #  input: Collect a range of values
      # sliderInput(inputId ="rng", label = "Range", value = c(10, 20), min = 0, max = 30),
      # customise slider input: https://shiny.rstudio.com/articles/sliders.html

      #  input: perform an action with a button
      # actionButton(inputId = "click", label = "Click here on this button", class =  "btn-block"),

      # output code : create code text in the ui and display using the server.
      # verbatimTextOutput("code"),

      # output: tables: output a static table, create code text in the ui and display using the server.
      # tableOutput("static"),

      # output: a dynamic table, create code text in the ui and display using the server.
      # dataTableOutput("dynamic"),


      # output: Plots: display a plot from ggplot
      # plotOutput("goodplot1", width = "400px"),

      tabsetPanel(
        tabPanel(
          title = "Manhattan",
          # output: Plot the manhattan plot using ggplot.
          plotOutput("manhattan1", width = "400px")
        ),
        tabPanel(
          title = "Gene Expression Table",
          # output: Table, create a reactable table rather than a still one
          reactableOutput("table")
        ),
        tabPanel(
          title = "PCA",

          ## output: Plot the pcs plot using ggplot.
          sliderInput("height", "Adjust the plot height", min = 100, max = 800, value = 250),
          sliderInput("width", "Adjust the plot width", min = 100, max = 800, value = 250),
          plotOutput("principal", width = "400px"),
          br(),
          br(),
          br(),
          br(),
          br(),
          sliderInput("a_height", "Adjust the plot height", min = 100, max = 800, value = 250),
          sliderInput("a_width", "Adjust the plot width", min = 100, max = 800, value = 250),
          plotOutput("principal_bar", width = "400px"),
        ),
        tabPanel(
          title = "K-Means",
          ## output: Plot the kmeans plot using ggplot.
          sliderInput("the_height", "Adjust the plot height", min = 100, max = 800, value = 250),
          sliderInput("the_width", "Adjust the plot width", min = 100, max = 800, value = 250),
          plotOutput("kmean2", width = "400px")
        ),
      )
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
