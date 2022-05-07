
# Instructions --------------------------------------------------------------------------------------------------------------------------------------------
# Define project functions ------------------------------------------------
# put / holds all the functions pertaining to the project

library(tidyverse, quietly = TRUE)
library(cowplot)
# ---------------------------------------------------------------------------------------------------------

# Convert the data to long format
# This said V
convert_to_long <- function(the_dataset) {
  the_dataset %>%
    pivot_longer((c(str_c("gene_", seq(1, 7129)))),
      names_to = "Gene",
      values_to = "expression_level",
      values_drop_na = TRUE
    )
}

# call the function
# convert_to_long()

# ---------------------------------------------------------------------------------------------------------

make_nested <- function(long_dataset, Gene) {
  long_dataset %>%
    # group the data by genes and put it in double brackets. 
    group_by(Gene) %>%
    # create a nested tibble composed of outcome and expression level.
    nest(data = c(value, expression_level))
}

# ungroup the data.
# ungroup()
# ---------------------------------------------------------------------------------------------------------

make_manhattan <- function(wrangled_dataset) {
  wrangled_dataset %>%
    ggplot(aes(
      x = Gene, y = neg_log10_p,
      colour = identified_as,
      label = gene_label
    )) +
    geom_point(
      alpha = 0.5,
      size = 2
    ) +
    geom_hline(
      yintercept = -log10(0.05),
      linetype = "dashed"
    ) +
    ggrepel::geom_label_repel(
      size = 5,
      max.overlaps = 15
    ) +
    theme_classic(base_family = "Helvetica") +
    theme(
      axis.text.x = element_blank(),
      legend.position = "bottom"
    ) +
    labs(
      x = "Gene",
      y = "Minus log10(p)",
      title = "Manhattan Plot"
    ) +
    scale_color_manual(values = c("#E7B860", "#00AFCC"))
}


# PCA -----------------------------------------------------------------------------------------------------------------------------------------------------

perform_pca <- function(provided_dataset) {
  provided_dataset %>% 
  select(where(is.numeric)) %>% # retain only numeric columns
  prcomp(scale = TRUE, center = TRUE)
}


# make a pca rotation table. 
make_rotation_table <- function(pca_fit) {
  pca_fit %>%
    tidy(matrix = "rotation")
}

