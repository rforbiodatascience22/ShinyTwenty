# Instructions  -------------------------------------------------------------------------------------------------------------------------------------------

# Remove invalid data, e.g. if you have amino acid sequence data,
# remove non-valid sequences containing X or other non-standard amino acid characters or fix columns,
# e.g. dates or when two labels are the same, but spelled differently


# Load libraries ----------------------------------------------------------
# The styler library is functional.
library("tidyverse", quietly = TRUE)

# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")

# Load data ---------------------------------------------------------------
my_data <- read_tsv(file = "data/01_my_data.tsv", show_col_types = FALSE)
my_data


# Wrangle data ------------------------------------------------------------
# 1.Change the raw data so that the values are numerical.
my_numerical_data <- my_data %>%
  mutate(value = case_when(
    outcome == "positive" ~ 0,
    outcome == "negative" ~ 1
  ))

my_numerical_data

# Write data --------------------------------------------------------------
my_data_clean <- my_numerical_data

write_tsv(
  x = my_data_clean,
  file = "data/02_my_data_clean.tsv"
)
