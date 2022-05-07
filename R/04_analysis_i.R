
# Instructions --------------------------------------------------------------------------------------------------------------------------------------------
# Perform analysis
# Analysis number 1

# Load libraries ----------------------------------------------------------
library("tidyverse", quietly = TRUE)
library("cowplot", quietly = TRUE)
library("ggthemes", quietly = TRUE)
library("broom")
library("hrbrthemes")
library("ggtech")
library("pheatmap")
library("ggrepel")

# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")

# Load data ---------------------------------------------------------------
my_data_clean_aug <- read_tsv(file = "data/03_my_data_clean_aug.tsv", show_col_types = FALSE)
my_data_clean_aug

# Load the clean data ---------------------------------------------------------------
west_clean_dat <- read_tsv(file = "data/02_my_data_clean.tsv", show_col_types = FALSE)
west_clean_dat


# Wrangle data ------------------------------------------------------------
west_data_long_nested <- my_data_clean_aug
west_data_long_nested


west_data_wide <- west_clean_dat %>%
  # pull the outcome, and all of the genes as columns out of the dataset.
  select(value, pull(west_data_long_nested, Gene))

west_data_wide


# Write out the table
write_tsv(
  x = west_data_wide,
  file = "results/04_my_west_data_wide.tsv"
)


# Model data (PCA) ---------------------------------------------------------------

set.seed(109)
pca_fit <- perform_pca(west_data_wide)
pca_fit

# There are 49 principal components created from the 7130 genes and their expression values.
# This is a dimension reduction technique.

broom_data <- pca_fit %>%
  broom::augment(west_data_wide) %>%
  # Find the first and second principal components.
  select(starts_with(".fitted"))

broom_data

# Visualise data ----------------------------------------------------------
# my_data_clean_aug

aug_dat_plot <- pca_fit %>%
  broom::augment(west_data_wide)

aug_dat_plot

# Make a heatmap of the gene expression data

# vis8 <- aug_dat_plot %>%
# select(2:49) %>%
# as.matrix() %>%
#  heatmap()
# vis8

# 4.

vis2 <- ggplot(
    data = aug_dat_plot,
    mapping = aes(x = .fittedPC4, y = .fittedPC1, 
                  shape = factor(value), 
                  colour = factor(value),
                  label = .rownames)
  ) +
  # make a scatter plot
  geom_point(size = 3, alpha = 0.8, position = "jitter") +
  
  geom_label_repel(
    mapping = aes(label = .rownames),
    hjust = 1, nudge_x = -0.02,
    max.overlaps = 10,
    color = "#904C2F"
  )+
  # edit the legend title and contents.
  scale_fill_discrete(name = "value", labels = c("0", "1")) +

  # set the theme to classic
  theme_classic(
    base_family = "Times",
    base_size = 8
  ) +
  theme_minimal() +

  # put the legend at the bottom and justify to the center.
  theme(
    legend.position = "top",
    legend.justification = "center"
  ) +
  scale_x_continuous(name = "Principal Component 1 : 24.0 %", limits = c(-10, 10)) +
  scale_y_continuous(name = "Principal Component 4 : 5.83 %", limits = c(-15, 20)) +
  # change the limits on the x and y axis, and keep the title.

  # final colour palette.
  scale_colour_excel_new() +
  labs(
    title = "Principal Components Analysis",
    subtitle = "Explained Variance for each Pricipal Component")

vis2



ggsave("results/visualisation2.png", vis2, width = 5, height = 5)


# Rotation Matrix -----------------------------------------------------------------------------------------------------------------------------------------


# The rotation matrix is pca_fit$rotation or tidy command.
pca_table <- make_rotation_table(pca_fit)
pca_table


# PCA Table -----------------------------------------------------------------------------------------------------------------------------------------------

# generate a tidy PCA table.((Why is the value in here??))
my_grand_pca_table <- pca_fit %>%
  tidy(matrix = "rotation") %>%
  pivot_wider(names_from = "PC", names_prefix = "PC", values_from = "value")

my_grand_pca_table

# Testing the heatmap.
library(pheatmap)

my_grand_pca_table %>%
  select(2:48) %>%
  as.matrix() %>%
  heatmap()

# Plot ----------------------------------------------------------------------------------------------------------------------------------------------

# Plot the first two principal components
vis3 <- my_grand_pca_table %>%
  ggplot(mapping = aes(x = PC1, y = PC2)) +
  geom_point(alpha = 0.5, colour = "darkblue") +

  # Add some text with the gene names.
  # geom_label_repel(
  #  mapping = aes(label = column),
  #  hjust = 1, nudge_x = -0.02, color = "#904C2F") +

  # Spruce
  theme_classic(
    base_family = "Helvetica",
    base_size = 12
  ) +

  # fix aspect ratio to 1:1
  coord_fixed() +

  # change the font size of the axes.
  theme_minimal_grid(12) +
  labs(
    title = "Principal Components Analysis",
    subtitle = " ",
    x = "1st Principal Component: 24.0 %",
    y = "2nd Principal Component: 7.52 % "
  )

vis3

ggsave("results/visualisation3.png", vis3, width = 5, height = 5)


# Principal Component Table. -------------------------------------------------------

# Get all rows and their principal components.

# pca_fit %>% tidy("pcs")
# or alternatively...
pca_fit %>%
  tidy(matrix = "eigenvalues") %>%
  mutate(percentage = percent * 100)



# Bar plot of Principal Components -----------------------------------------------------------



vis4 <- pca_fit %>%
  tidy(matrix = "eigenvalues") %>%
  # Make a bar plot of the principal components.
  ggplot(mapping = aes(x = PC, y = percent)) +

  # make a bar plot
  geom_col(colour = "darkblue", fill = "#56B4E8", alpha = 0.5) +

  # Add a line and then some points.
  geom_line() +
  geom_point(shape = 21, color = "black", fill = "#69b3a2", size = 2) +

  # Adjust the x axis and the y axis.
  scale_x_continuous(breaks = 1:20, limits = c(0, 20)) +
  scale_y_continuous(labels = scales::percent_format(), expand = expansion(mult = c(0, 0.01))) +

  # Add a grid
  theme_minimal_hgrid(12) +
  theme_classic(
    base_family = "Helvetica",
    base_size = 12
  ) +
  theme(
    axis.text.x = element_text(angle = 50, hjust = 1, size = 7, vjust = 1)
  ) +

  # Add some labels.
  labs(
    y = "Variance explained by each PC",
    x = "The Principal Component",
    title = " ",
    subtitle = "Title: Scree Plot",
    caption = " "
  )

vis4
ggsave("results/visualisation4.png", vis4, width = 5, height = 5)

# In multivariate statistics, a scree plot is a line plot of the eigenvalues of factors or
# principal components in an analysis.
# The scree plot is used to determine the number of factors to retain in an exploratory factor analysis
# or principal components to keep in a principal component analysis.


# The first component captures over 24.0 % of the variation in the data,
# and the second component captures 7.52 % of the data.
# Is this enough to separate outcome 0 from outcome 1 in the scatter plot?

# Write data --------------------------------------------------------------

principal_component_eig_table <- pca_fit %>%
  tidy(matrix = "eigenvalues") %>%
  mutate(percentage = percent * 100)

# Write out the table
write_tsv(
  x = principal_component_eig_table,
  file = "results/01_my_results_pca_eig.tsv"
)

# Write out the table
write_tsv(
  x = my_grand_pca_table,
  file = "results/03_my_results_grand_pca.tsv"
)
