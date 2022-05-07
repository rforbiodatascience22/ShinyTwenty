
# Instructions --------------------------------------------------------------------------------------------------------------------------------------------
# Add new variables to your data

# Load libraries ----------------------------------------------------------
library("tidyverse", quietly = TRUE, warn.conflicts = FALSE)
library(broom)
library(ggrepel)

# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")

# Load data ---------------------------------------------------------------
my_data_clean <- read_tsv(file = "data/02_my_data_clean.tsv", show_col_types = FALSE)
my_data_clean


# Wrangle data ------------------------------------------------------------

# 1. Use pivot longer to convert the data into a long format
# Place in three columns.
gene_data_long <- convert_to_long(my_data_clean)
gene_data_long


# 2. Create a nested tibble.
west_data_nested <- make_nested(gene_data_long, `Gene`)
west_data_nested


# 3. Fit logistic regression models on the data.
west_data_nested_mod <- west_data_nested %>%
  mutate(model = map(data, ~ glm(value ~ expression_level,
    data = .,
    family = binomial(link = "logit")
  )))
west_data_nested_mod



# 4. Extract some information from each of the models.
west_data_nested_sum <- west_data_nested_mod %>%
  # for each model, generate tidy data with  estimate, std.error, statistic, p-value
  mutate(tidied_model = map(model, broom::tidy, conf.int = TRUE)) %>%
  # take the tidied model out of a tibble and show it.
  unnest(tidied_model)

west_data_nested_sum


# 5.  Now, we are only interested in the terms for the genes, so remove the intercept rows.
west_data_long_nested <- west_data_nested_sum %>%
  filter(str_detect(term, "expression_level"))

west_data_long_nested


# 6. Add an indicator variable
# Denoting if a given term for a given gene is significant (p < 0.05 p< 0.05 p <0.05

gene_expr_data_long_nested <- west_data_long_nested %>%
  mutate(
    identified_as = case_when(
      p.value < 0.05 ~ "Significant",
      TRUE ~ "Non-significant"
    ),
    gene_label = case_when(
      identified_as == "Significant" ~ Gene,
      identified_as == "Non-significant" ~ ""
    ),

    # Calculate negative logs of p-values
    neg_log10_p = -log10(p.value)
  )



# 6.5 Select only the data with the lowest p values ( First only the significant genes ) 
gene_expr_data_long_nested  <- gene_expr_data_long_nested %>% 
  filter(identified_as == "Significant") %>% 
  arrange(p.value) %>% 
  # Get the first 100 rows.
  head(100)
  
gene_expr_data_long_nested

# write out this data. 
gene_expr_data_long_nested

write_tsv(
  x = gene_expr_data_long_nested,
  file = "results/05_manhattan_dataset.tsv"
)


# 7. Visualise Associations.
viz1 <- make_manhattan(gene_expr_data_long_nested)
viz1

ggsave("results/visualisation1.png", viz1, width = 5, height = 5)


# Write data --------------------------------------------------------------

my_data_clean_aug <- gene_expr_data_long_nested %>% 
  select("Gene", "term", "estimate", "std.error", "statistic", "p.value", "conf.low", "conf.high")

my_data_clean_aug


# Write data --------------------------------------------------------------
write_tsv(
  x = my_data_clean_aug,
  file = "data/03_my_data_clean_aug.tsv"
)

