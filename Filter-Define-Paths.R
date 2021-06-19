##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: June 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
#library("tidyverse")

#Make Dataframe if necessary
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
df_AX81 <- read_delim("Documents/new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames)

#filter dataframe on, interesting file formats

dplyr::filter(df_AX81)

#Let's start with what summarise can tell me
?summarise()
summarise(df_AX81$subdirectory3)

#Hm, not applicable to object of class "character" , which makes sense, and I did not think of that
#First, to treat, subdirectory3, 4, 5, hell all of them, as, cateogries

df_AX81$subdirectory3 <- as.factor(df_AX81$subdirectory3)
df_AX81 %>%
  group_by(subdirectory3)
