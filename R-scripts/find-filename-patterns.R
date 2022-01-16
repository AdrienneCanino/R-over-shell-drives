##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: January 2022
#git repo for folder with script, etc
#new.invs too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#This is a single script aimed at getting filenames out of the clean deployment dfs


#install.packages('tidyverse')
library("tidyverse")
library("stringi")

#First, let's do this on one file first - let's go with 72
getwd() #assumes answer is git repo folder and new.invs is a sibling folder
setwd("~/Documents/R-over-shell-drives") #make sure you're in the repo as needed
#make a vector that builds the header for this dataframe
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

df <- read.delim("../new.invs/shell.ax72", sep="/",
                      col.names = columnNames, header = FALSE, comment.char="",
                      blank.lines.skip=FALSE, fill =TRUE)
#make a column in a dataframe that has the filepath included
df<- 
  as_tibble(df) %>% 
  distinct() %>%
  unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

#trim the ends where NAs somehow, perpetuated?
df$file_path <- trimws(df$file_path, which="right", whitespace="/")

#Get any csv files in this drive
csvs_index72 <-str_which(df$file_path, regex(".csv$", ignore_case=TRUE))
df_csvs <-  df[csvs_index72,]
write_lines(df_csvs$file_path, "./ax72-CSV-file-paths.txt")

#in shell, via remote connection to the drives: rsync -ar --no-relative / --files-from=/home/adrienne/Documents/R-over-shell-drives/ax72-CSV-file-paths.txt /home/adrienne/Documents/R-over-shell-drives/CSV-copied

#the caps are important in line 38

#Got 2 deployment info csvs, as expected

#let's clean them up
#get list of csvs as a list object
#wd and path can be touchy here
setwd("./CSV-copied")
files <- list.files(path="./", pattern ="*.csv")

#make a list to iterate through

deploydflst <- NULL
i <- 1
testlst <-  NULL
#pull in the deploymentInfo csvs as ugly dataframes in order to extract their fixed information (hopefully)
for (f in files){
  #look for number of cols
  wideness <- count.fields(f,sep=",", comment.char = "",skip=5,blank.lines.skip = FALSE)
  wideness <- max(wideness)
  #make dataframe
  dat <-read.table(f, 
                   header=F, sep="," ,
                   blank.lines.skip = FALSE, comment.char="", 
                   colClasses = c("character","character", "character"),
                   col.names = 1:wideness) #read table
  nam <- paste("ax72","deployDF", i, sep = "_")
  print(nam)
  assign(nam, dat)
  #make a list to iterate through
  testlst[[i]] <- nam
  i <- i+1
}
#that list isn't what I want, it's just names without pointing to the object DF in R, but this is:
deploydflst <- lapply(testlst, get)

#clean up what I don't need from that loop
rm(wideness, dat, nam,f)
#OK, those are very ugle dataframes.
#now to make them nicer
#go through the dataframes and make them clean deployment dataframes with tidy/long details
freqPoints <- NULL
i=1
cleandeployDFslst = NULL
for (thing in deploydflst){
  
  #pull those three values out
  clientid <- as.character(thing[3,2])
  region<- as.character(thing[3,3])
  period <- as.character(thing[3,4])
  freqPoints <- (thing[5,2:(length(thing))])
  freqPoints <-
    freqPoints %>% stri_remove_empty(na_empty=TRUE) %>% as.character()
  print(freqPoints)
  
  #build the header for this one
  #less that column that describes but no with value the freqpoints cols
  #needs stringi library 
  tmp <- thing[6,1:24] %>% as.character()
  print(tmp)
  hdr <- c(tmp, freqPoints)
  cat("this is the header",hdr)
  
  #trim the df to the cols/rows of deploy info
  thing <- thing %>%
    slice(-c(1:6))
  colnames(thing) <- hdr
  print(head(thing))
  
  #add the columns of the fixed information
  thing <-  add_column(thing, .before="recorderId", clientid=clientid,region=region,period=period)
  
  #rename the deployment dataframe
  nam <- paste("cleandeployDF", i, sep = "_")
  print(nam)
  assign(nam, thing)
  cleandeployDFslst[[i]] <- nam
  i <- i+1
}

#make a list pointing at the data frame object not just the names of those objects
cleandeplydflst <- lapply(cleandeployDFslst, get)
cleandeplydflst


#Clean up my environmentafter that loop
rm(freqPoints, files, hdr, i, nam, tmp, wideness, f, clientid, region, period)
rm(thing, dat, testlst, deploydflst)

#OK, I can see the clean deployment frame with 1 row, that's, approrpiate because the ugly one had only one deployment to talk about. so. It worked.

#Now, there's a column called 'fileStructure'
head(cleandeployDF_2)
#it's col 14

#These have .wav in th efilename structure, which makes sense since I know a count of .wav files in 72 gives a high number. It will not be the case in other drives. I assume that 0000 is a holding point for month?

#extract those file structures, and name them in a meaningful way -> as another object in the environment, or another plain text output for the project?

pattrns <-  NULL
for (thing in cleandeplydflst){
  
  val <-unique(thing[,14]) #get unique value out of 14th column, file structure
  pattrns <-  append(pattrns, val) #add to list
  #pattrns <-  unique(pattrns) #Do I want only the unique ones across both df?
}

#find those file paths
pattrns[1] 
a <- str_which(df$file_path, pattrns[1]) #this needs to be, what, a fuzzy match? Or I need to prune the value of pattrns[1] somehow to only match the ...start of the file?

df_ax81[a,]
seasons_match <-  pattrns
