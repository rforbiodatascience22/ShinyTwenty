# Instructions  -------------------------------------------------------------
# Collapse data to a single file or convert .xlsx to .tsv
# here we could imagine having an .xlsx-file with multiple sheets,
# from which we create a single .tsv

# load libraries ----------------------------------------------------------
library(tidyverse, quietly = TRUE)
library(vroom, quietly = TRUE)
library(tidyr)
library(stringr, quietly = TRUE)

# Set the working directory to the path containing the project files. 
# setwd("HPC_Project/")
# Do all the links need to be not hard links??

# Define functions  -------------------------------------------------------
source(file ="R/99_project_functions.R")

# Load data ---------------------------------------------------------------
west_raw <- load("data/_raw/west.RData")
west_raw

# The data table.
values <- as_tibble(west$x, .name_repair)
values

# the y variable.
outcome <- as_tibble(west$y)
outcome


# merge the data together (but there are no common variables)
my_raw_data <- bind_cols(outcome, values)
my_raw_data

# Change the column names to say gene_X instead of V
my_raw_data_renamed <- my_raw_data %>%
  rename_with(~ gsub("[V]", "gene_", .x))

my_raw_data_renamed

# Write data --------------------------------------------------------------
write_tsv(
  x = my_raw_data_renamed,
  file = "data/01_my_data.tsv"
)

