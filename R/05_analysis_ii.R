
# Instructions --------------------------------------------------------------------------------------------------------------------------------------------
# Perform analysis
# Analysis number 2 : Kmeans 


# Load libraries ----------------------------------------------------------
library("tidyverse", quietly = TRUE)
library("factoextra", quietly = TRUE)
library("cowplot", quietly = TRUE)
library("ggthemes", quietly = TRUE)

# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
my_data_clean_aug <- read_tsv(file = "data/03_my_data_clean_aug.tsv",show_col_types = FALSE)
my_data_clean_aug

# Load the clean data ---------------------------------------------------------------
west_clean_dat <- read_tsv(file = "data/02_my_data_clean.tsv",show_col_types = FALSE)
west_clean_dat


# Wrangle data ------------------------------------------------------------
west_data_long_nested <- my_data_clean_aug
west_data_long_nested 

west_data_wide <- west_clean_dat %>%
  # pull the outcome, and all of the genes as columns out of the dataset.
  select(value, pull(west_data_long_nested, Gene))

west_data_wide


# Model data
# Visualise data ----------------------------------------------------------

# Question: Are these right genes to choose? 

# Perform K means clustering on two selected genes.
kclust <- west_data_wide %>%
  select(gene_132, gene_117) %>%
  kmeans(centers = 2, algorithm = "Hartigan-Wong")

kclust

# Add the point classifications(clusters) to the original dataset. :
# note: the last column is .cluster.
augment(kclust, west_data_wide)

# .2

aug_kmean_plot <- augment(kclust, west_data_wide)


# plot the clusters.
vis5 <-
  ggplot(data = aug_kmean_plot,
         
         mapping = aes(x = gene_132, y = gene_117, shape = .cluster, color = .cluster, fill = .cluster)) +

  # create a scatter plot.
  geom_point(colour = "darkblue", pch = 21, size = 6, alpha = 0.3) +

  # Add a colour from ggthemes.
  #scale_fill_discrete() +
  scale_fill_manual(values = c("chocolate1", "seagreen3", "midnightblue", "plum")) +
  # scale_color_manual(values = c("#00AFBB", "#E7B800", "#FC4E07"))

  # Add the ellipse that i long for.
  stat_ellipse(type = "norm", linetype = 1, geom = "polygon", level = 0.8, alpha = 0.1) +
  labs(
    title = "KMeans Cluster Plot"
  )+
# Change the theme.
theme_minimal_grid()

vis5

ggsave("results/visualisation5.png", vis5, width = 5, height = 5)


# .3
# The cluster centroids are called centers
kclust$centers

# .4
# summarise the data on a per cluster level.
tidy(kclust)

# 5. extract a single row summary.
glance(kclust)


vis6 <- fviz_nbclust(x = west_data_wide, kmeans, method = "wss") +
  geom_vline(xintercept = 2, linetype = 2)

vis6

ggsave("results/visualisation6.png", vis6, width = 5, height = 5)


# 6.
vis7 <- fviz_cluster(kclust,
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

ggsave("results/visualisation7.png", vis7, width = 5, height = 5)


# Write data --------------------------------------------------------------

# Write out the results table
write_tsv(
  x = aug_kmean_plot,
  file = "results/02_my_results_kmean_aug.tsv"
)

