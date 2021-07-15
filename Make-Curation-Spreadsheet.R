##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: July 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")

#Make Dataframe if necessary
#use the files in a neighboring folder to the git repo folder, because, too big to be happy with github.com

columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
df_AX81 <- read_delim("Documents/new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames)
#this does throw errors, about, parsing 12 columns of information where only 5 values can be pulled out of the txt file.
#I think it's ok.

#Or, check if I still have my environment
df_wavs81
