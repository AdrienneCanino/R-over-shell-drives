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

#columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
#df_AX81 <- read_delim("Documents/new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames)
#this does throw errors, about, parsing 12 columns of information where only 5 values can be pulled out of the txt file.
#I think it's ok.

#Or, check if I still have my environment
df_wavs81

#So I left off needing to put everything together into a useful dataframe. 
#It's gonna be harder than expected. 

#first, the things we want in the spreadsheet

header <- c("drive","file-path", "instrument-name", "start-year", "stationID", "recorderID", "lat", "long", "file-type","file-count","total-volume","preserve-decision")
curation_df <- data.frame(matrix(nrow=10, ncol=length(header)))
colnames(curation_df) <- header
curation_df
?tibble

curation_df$drive == "ax81"
curation_df$`file-path` <- "mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40"
curation_df$`file-count` <- 5988
curation_df$`start-year` <-  2009

curation_df <- curation_df[-c(2:10)]

amar219yada_filepaths[1]
newRow <- data.frame(drive = "ax81", `file-path`="mnt/shell/ax81/fw/chukchi/2013-overwinter/CL05/stitiched wavs/AMAR219.1.16000.M8EV35dB/", `file-count`=7154, `start-year`=2013, "instrument-name", "stationID", "recorderID", "lat", "long", "file-type","total-volume","preserve-decision")
curation_df <- rbind(curation_df, newRow )

