#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import reactable
#' @import shiny
#' @import dplyr
#' @import tibble
#' @import stringr
#' @import ggplot2
#' @import ggrepel
#' @import ggthemes
#' @import cowplot
#' @import factoextra
#' @import forcats
#' @noRd
app_server <- function(input, output, session) {

  # serve the text
  # output$text <- renderText({" Hello. " })

  # serve the text called code
  # output$code <- renderPrint({summary(1:10)})

  # serve the static id to render a static table.
  # output$static <- renderTable(head(mtcars))

  # serve the dynamic id to render a dynamic table.
  # output$dynamic <- renderDataTable(mtcars, options = list(pageLength = 4))

  # serve a reactable table using the react library.(((mtcars))) ***
  output$table <- renderReactable({
    reactable(my_data_clean_aug, defaultPageSize = 5, bordered = TRUE)
  })

  # serve a goodplot which can also act as an input.
  # output$goodplot <- renderPlot(plot(1:5), res = 96)

  # serve a manhattan plot which can also act as an input.
  output$manhattan1 <- renderPlot(manhunten, res = 96)

  # serve the principal component plot which can also act as input.
  output$principal <- renderPlot(
    width = function() input$width,
    height = function() input$height,
    res = 96,
    {
      vis2
    }
  )

  output$principal_bar <- renderPlot(
    width = function() input$a_width,
    height = function() input$a_height,
    res = 96,
    {
      vis4
    }
  )
  # get the kmeans plot.
  output$kmean2 <- renderPlot(
    width = function() input$the_width,
    height = function() input$the_height,
    res = 96,
    {
      vis5
    }
  )


  # 01_load -------------------------------------------------------
  devtools::install_github("rforbiodatascience22/Twenty")
  library(Twenty)

  # look at the available datasets in Twenty
  #data(package = "Twenty")

  #m <- load("data/_raw/west.RData")

  # load the original raw data.
  m <- data("west")
  m

  # The data table.
  values <- tibble::as_tibble(west$x, .name_repair)

  # the y variable.
  outcome <- tibble::as_tibble(west$y)

  # merge the data together (but there are no common variables)
  my_raw_data <- dplyr::bind_cols(outcome, values)
  my_raw_data

  # Change the column names to say gene_X instead of V
  my_raw_data_renamed <- my_raw_data %>%
    dplyr::rename_with(~ gsub("[V]", "gene_", .x))

  my_raw_data_renamed

  # 02_clean --------------------------------------------------------

  my_data <- my_raw_data_renamed

  my_numerical_data <- my_data %>%
    dplyr::mutate(value = dplyr::case_when(
      outcome == "positive" ~ 0,
      outcome == "negative" ~ 1
    ))

  my_data_clean <- my_numerical_data
  my_data_clean

  # 03_augment ---------------------------------------------------------

  gene_data_long <- Twenty::convert_to_long(my_data_clean)
  gene_data_long

  west_data_nested <- Twenty::make_nested(gene_data_long, `Gene`)
  west_data_nested


  # Fit logistic regression models on the data.
  west_data_nested_mod <- west_data_nested %>%
    dplyr::mutate(model = purrr::map(data, ~ glm(value ~ expression_level,
      data = .,
      family = binomial(link = "logit")
    )))
  # west_data_nested_mod

  # Extract some information from each of the models.
  west_data_nested_sum <- west_data_nested_mod %>%
    # for each model, generate tidy data with  estimate, std.error, statistic, p-value
    dplyr::mutate(tidied_model = purrr::map(model, broom::tidy, conf.int = TRUE)) %>%
    # take the tidied model out of a tibble and show it.
    tidyr::unnest(tidied_model)

  # 5.  Now, we are only interested in the terms for the genes, so remove the intercept rows.
  west_data_long_nested <- west_data_nested_sum %>%
    dplyr::filter(stringr::str_detect(term, "expression_level"))

  # . 6 Indicator variable
  gene_expr_data_long_nested <- west_data_long_nested %>%
    dplyr::mutate(
      identified_as = dplyr::case_when(
        p.value < 0.05 ~ "Significant",
        TRUE ~ "Non-significant"
      ),
      gene_label = dplyr::case_when(
        identified_as == "Significant" ~ Gene,
        identified_as == "Non-significant" ~ ""
      ),

      # Calculate negative logs of p-values
      neg_log10_p = -log10(p.value)
    )

  # 6.5 Select only the data with the lowest p values ( First only the significant genes )
  gene_expr_data_long_nested <- gene_expr_data_long_nested %>%
    dplyr::filter(identified_as == "Significant") %>%
    dplyr::arrange(p.value) %>%
    # Get the first 100 rows.
    utils::head(100)



  manhunten <- gene_expr_data_long_nested %>%
    ggplot2::ggplot(mapping = ggplot2::aes(
      x = Gene, y = neg_log10_p,
      colour = identified_as,
      label = gene_label
    )) +
    ggplot2::geom_point(
      alpha = 0.5,
      size = 2
    ) +
    ggplot2::geom_hline(
      yintercept = -log10(0.05),
      linetype = "dashed"
    ) +
    ggrepel::geom_label_repel(
      size = 5,
      max.overlaps = 15
    ) +
    ggplot2::theme_classic(base_family = "Helvetica") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      legend.position = "bottom"
    ) +
    ggplot2::labs(
      x = "Gene",
      y = "Minus log10(p)",
      title = "Manhattan Plot"
    ) +
    ggplot2::scale_color_manual(values = c("#E7B860", "#00AFCC"))



  my_data_clean_aug <- gene_expr_data_long_nested %>%
    dplyr::select(
      "Gene", "term", "estimate", "std.error", "statistic",
      "p.value", "conf.low", "conf.high"
    )

  my_data_clean_aug

  # 04_analysis ---------------------------------------------------------

  west_data_long_nested <- my_data_clean_aug
  west_data_long_nested

  west_clean_dat <- my_data_clean

  west_data_wide <- west_clean_dat %>%
    # pull the outcome, and all of the genes as columns out of the dataset.
    dplyr::select(value, dplyr::pull(west_data_long_nested, Gene))

  west_data_wide

  # Model data (PCA) ---------------------------------------------------------------

  set.seed(109)
  pca_fit <- Twenty::perform_pca(west_data_wide)
  pca_fit

  aug_dat_plot <- pca_fit %>%
    broom::augment(west_data_wide)

  aug_dat_plot

  # ____________________________________________________#

  vis2 <- ggplot2::ggplot(
    data = aug_dat_plot,
    mapping = aes(
      x = .fittedPC4, y = .fittedPC1,
      shape = factor(value),
      colour = factor(value),
      label = .rownames
    )
  ) +
    # make a scatter plot
    ggplot2::geom_point(size = 3, alpha = 0.8, position = "jitter") +
    ggrepel::geom_label_repel(
      mapping = aes(label = .rownames),
      hjust = 1, nudge_x = -0.02,
      max.overlaps = 10,
      color = "#904C2F"
    ) +
    # edit the legend title and contents.
    ggplot2::scale_fill_discrete(name = "value", labels = c("0", "1")) +

    # set the theme to classic
    ggplot2::theme_classic(
      base_family = "Times",
      base_size = 8
    ) +
    ggplot2::theme_minimal() +

    # put the legend at the bottom and justify to the center.
    ggplot2::theme(
      legend.position = "top",
      legend.justification = "center"
    ) +
    ggplot2::scale_x_continuous(name = "Principal Component 1 : 24.0 %", limits = c(-10, 10)) +
    ggplot2::scale_y_continuous(name = "Principal Component 4 : 5.83 %", limits = c(-15, 20)) +
    # change the limits on the x and y axis, and keep the title.

    # final colour palette.
    ggthemes::scale_colour_excel_new() +
    ggplot2::labs(
      title = "Principal Components Analysis",
      subtitle = "Explained Variance for each Principal Component"
    )

  vis2


  pca_table <- Twenty::make_rotation_table(pca_fit)
  pca_table

  my_grand_pca_table <- pca_fit %>%
    broom::tidy(matrix = "rotation") %>%
    tidyr::pivot_wider(names_from = "PC", names_prefix = "PC", values_from = "value")

  my_grand_pca_table

  # Plot the first two principal components
  vis3 <- my_grand_pca_table %>%
    ggplot2::ggplot(mapping = aes(x = PC1, y = PC2)) +
    ggplot2::geom_point(alpha = 0.5, colour = "darkblue") +

    # Add some text with the gene names.
    # geom_label_repel(
    #  mapping = aes(label = column),
    #  hjust = 1, nudge_x = -0.02, color = "#904C2F") +

    # Spruce
    ggplot2::theme_classic(
      base_family = "Helvetica",
      base_size = 12
    ) +

    # fix aspect ratio to 1:1
    ggplot2::coord_fixed() +

    # change the font size of the axes.
    cowplot::theme_minimal_grid(12) +
    ggplot2::labs(
      title = "Principal Components Analysis",
      subtitle = " ",
      x = "1st Principal Component: 24.0 %",
      y = "2nd Principal Component: 7.52 % "
    )

  vis3
  # Principal Component Table. -------------------------------------------------------

  # Get all rows and their principal components.

  # pca_fit %>% tidy("pcs")
  # or alternatively...
  pca_fit %>%
    broom::tidy(matrix = "eigenvalues") %>%
    dplyr::mutate(percentage = percent * 100)

  # Bar plot of Principal Components ------------------------------------------------

  vis4 <- pca_fit %>%
    broom::tidy(matrix = "eigenvalues") %>%
    # Make a bar plot of the principal components.
    ggplot2::ggplot(mapping = aes(x = PC, y = percent)) +

    # make a bar plot
    ggplot2::geom_col(colour = "darkblue", fill = "#56B4E8", alpha = 0.5) +

    # Add a line and then some points.
    ggplot2::geom_line() +
    ggplot2::geom_point(shape = 21, color = "black", fill = "#69b3a2", size = 2) +

    # Adjust the x axis and the y axis.
    scale_x_continuous(breaks = 1:20, limits = c(0, 20)) +
    scale_y_continuous(labels = scales::percent_format(), expand = expansion(mult = c(0, 0.01))) +

    # Add a grid
    cowplot::theme_minimal_hgrid(12) +
    ggplot2::theme_classic(
      base_family = "Helvetica",
      base_size = 12
    ) +
    ggplot2::theme(
      axis.text.x = element_text(angle = 50, hjust = 1, size = 7, vjust = 1)
    ) +

    # Add some labels.
    ggplot2::labs(
      y = "Variance explained by each PC",
      x = "The Principal Component",
      title = " ",
      subtitle = "Title: Scree Plot",
      caption = " "
    )

  # 05_analysis ii ---------------------------------------------------------
  # Model data
  # Visualise data ----------------------------------------------------------

  # Perform K means clustering on two selected genes.
  kclust <- west_data_wide %>%
    dplyr::select(gene_132, gene_117) %>%
    stats::kmeans(centers = 2, algorithm = "Hartigan-Wong")

  kclust

  # Add the point classifications(clusters) to the original dataset. :
  # note: the last column is .cluster.
  broom::augment(kclust, west_data_wide)

  # .2
  aug_kmean_plot <- broom::augment(kclust, west_data_wide)


  # plot the clusters.
  vis5 <-
    ggplot2::ggplot(
      data = aug_kmean_plot,
      mapping = aes(x = gene_132, y = gene_117, shape = .cluster, color = .cluster, fill = .cluster)
    ) +

    # create a scatter plot.
    ggplot2::geom_point(colour = "darkblue", pch = 21, size = 6, alpha = 0.3) +

    # Add a colour from ggthemes.
    # scale_fill_discrete() +
    ggplot2::scale_fill_manual(values = c("chocolate1", "seagreen3", "midnightblue", "plum")) +
    # scale_color_manual(values = c("#00AFBB", "#E7B800", "#FC4E07"))

    # Add the ellipse that i long for.
    stat_ellipse(type = "norm", linetype = 1, geom = "polygon", level = 0.8, alpha = 0.1) +
    ggplot2::labs(
      title = "KMeans Cluster Plot"
    ) +
    # Change the theme.
    cowplot::theme_minimal_grid()

  vis5


  # .3
  # The cluster centroids are called centers
  kclust$centers

  # .4
  # summarise the data on a per cluster level.
  broom::tidy(kclust)

  # 5. extract a single row summary.
  broom::glance(kclust)


  vis6 <- factoextra::fviz_nbclust(x = west_data_wide, kmeans, method = "wss") +
    geom_vline(xintercept = 2, linetype = 2)

  vis6


  # 6.
  vis7 <- factoextra::fviz_cluster(kclust,
    data = west_data_wide,
    palette = c("#00AFBB", "#E7B800", "#FC4E07"),
    main = "K Means Cluster Plot for West Data",
    ellipse.type = "euclid",
    # star.plot = TRUE,
    repel = TRUE,
    # Avoid label over plotting
    ggtheme = theme_minimal()
  )

  vis7
}
