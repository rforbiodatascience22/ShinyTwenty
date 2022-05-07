# Run the code from all of the scripts ---------------------------------------------------------
# Set the working directory to the path containing the project files. 

setwd("/Users/m.o.l.s/Desktop/HPC_Project")

source(file = "R/01_load.R")
source(file = "R/02_clean.R")
source(file = "R/03_augment.R")
source(file = "R/04_analysis_i.R")
source(file = "R/05_analysis_ii.R")
source(file = "R/99_project_functions.R")
 
# Turn the RMarkdown file into an ioslides presentationn and 
# add a call to knitr at the end of this script to run the RMarkdown Presentation using ((knit))
library(knitr)

knitr::knit("doc/ioslides_presentation/Presentation.Rmd")


# Turn the R Script into an RMarkdown file using ((spin))
#knitr::spin(hair = "R/02_clean.R", knit = TRUE)

# Notes: Run the presentation from the R Script. 
# Generate the R package and the Shiny App separately 
# The HPC Cluster is different from the Package and different from the Shiny App 
# so there is no need to link these. 
# They can be separate.
