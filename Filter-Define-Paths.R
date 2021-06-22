##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: June 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")

#Make Dataframe if necessary
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
df_AX81 <- read_delim("Documents/new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames)
#this does throw errors, about, parsing 12 columns of information where only 5 values can be pulled out of the txt file.
#I think it's ok.


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

#7 groupings off subdirectory
?factor
subdirectoriesLVL3_ax81 <- levels(df_AX81$subdirectory3)

#this is a terrible name for an object

sub3_lvls <- subdirectoriesLVL3_ax81

rm(subdirectoriesLVL3_ax81)

sub3_lvls
#".Trash-1001"                "$RECYCLE.BIN"               "fw"                         "RECYCLER"                  
#"shell"                      "Shell Shallow Hazards 2013" "System Volume Information" 

#not that useful, let's go back to finding the file extension I'm interested in

#let's build a vector of the index numbers where the value ends in .csv, and store that as an object, then use that object to subset the whole df
#first, find where values end in .csv 

str_locate()


