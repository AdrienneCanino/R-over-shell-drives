##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: November 2021
#git repo for folder with script, etc
#new.invs too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#This do it all take two is about, getting to a more streamlined process, while also testing the process on a drive other than 81. let's do, 72?

#install.packages('tidyverse')
library("tidyverse")
library("stringi")
#Make the dataframes of the drive directories/file paths csv and wav files specifically ----------------------------------------------
#store the drive you're aiming at, just in case

todays_drive <- "shell.ax72"

#make a vector that builds the header for this dataframe
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

##check your 20 --- DO THIS BY HAND--------------------------
getwd() #assumes answer is git repo folder and new.invs is a sibling folder
setwd("~/Documents/R-over-shell-drives") #make sure you're in the repo as needed

#write and assign the thing by reading in the lines, carefully, this is a finicky piece of code-------------------------
df_ax72 <- read.delim("../new.invs/shell.ax72", sep="/",
                      col.names = columnNames, header = FALSE, comment.char="",
                      blank.lines.skip=FALSE, fill =TRUE)


#make a column in a dataframe that has the filepath included
df <- 
  as_tibble(df_ax72) %>% 
  mutate_all(as.character) %>%
  unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

#trim the ends where NAs somehow, perpetuated?
df$file_path <- trimws(df$file_path, which="right", whitespace="/")

#De-dupe the dataframe
df <- df %>% 
  distinct()

#use that col of file paths to find the csvs in this drive
csvs_index <-str_which(df$file_path, regex(".csv$", ignore_case=TRUE))
length(csvs_index) #2, as expected

df_csvs <- df[csvs_index,]

#same, find the wavs in this drive
wavs_index <- str_which(df$file_path, regex(".wav$", ignore_case=TRUE, ))

length(wavs_index)
#so 23414 wav files

df_wavs <-df[wavs_index,]


#Write out any useful dataframe files, like csv and wav filepaths---------------------
write_lines(df_wavs$file_path, file=paste(todays_drive, "wave-file-paths.txt", sep="_"))
write_lines(df_csvs$file_path, file=paste(todays_drive, "csv-file-paths.txt", sep="_"))

#Remove anything from my environment that I don't need now
rm(df_csvs, df_wavs,
   csvs_index, wavs_index)
#filtering, counting, and summarising the files on this drive 

#Make the deployment info spreadsheets cleaner, with unfortunately complicated loops-----------------------------------------------

#a step in bash is missing from this R code, where a remote drive was accessed and the csvs that the file_paths point to were copied to a folder in this repo

## loop 1 - get a list of dataframe for the csvs--------------
##This is a loop that can do a read file to data from from wd, worked well as just that function

#these deployment info files, the csvs identified in the export on line 55, gotta be in the repo, gotta have those csvs from Shell's messy harddrives in a subdir 'CSV-copied'
#wd and path can be touchy here
files <- list.files(path="./CSV-copied", pattern ="*.csv")

#make a list to iterate through

deploydflst <- NULL
i <- 1
testlst <-  NULL
#operate the loop in the folder where the csvs exist DO THIS PART BY HAND
setwd("./CSV-copied")

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
  nam <- paste("deployDF", i, sep = "_")
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


## Loop 2, make the ugly dataframes clean deployment dataframes ---------------------------------------
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
rm(cleandeployDFslst, 
   deployDF_1, deployDF_2, deployDF_3)

##Write out anything useful from these loops, like the clean deploymentInfo spreadhseet-----------------
write_csv(cleandeployDF_1, file="../ax_72_deploy1.csv")
write_csv(cleandeployDF_2, file="../ax_72_deploy2.csv")
#write_csv(cleandeployDF_3, file="../ax_81_deploy3.csv")


## fine the deployment periods for each clean deployment dataframe ------------------------
pattrns <-  NULL
for (thing in cleandeplydflst){
  
  val <-unique(thing[,4]) #get unique value out of 4thh  column, period
  pattrns <-  append(pattrns, val) #add to list
  #pattrns <-  unique(pattrns)
}
## Check assumption - each deployment file is for one deployment period only? #not for ax72

#find those file paths
pattrns[1] 
a <- str_which(df$file_path, pattrns[1]) 
df[a,]
seasons_match <-  pattrns

# find the season for first clean deployment df
period <- seasons_match[1]

#Subset the dataframe to it
temp_index <- str_which(df$file_path, regex(period))

#what does that look like
slice(df, temp_index)

df %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()

#now, looking for only wav files in this instance
wavs_index81 <- str_which(df$file_path, regex(".wav$", ignore_case=TRUE))

length(wavs_index81)

#what does it look like, only wav files, in only this period
df %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()

#might need to check/set this
getwd()

# write the file path locations out with the information for the deployment file in the file name I guess? shudder
df %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  as.data.frame() -> t

write_lines(t$file_path, file="./dfax72_cleandeployDF1_related-wav-file-paths.txt", sep="\n", append=FALSE)

## Repeating that process for the other clean deployment dfs from the drive ---------------------
### In the case of drive 72, it will not be any use, because the period pulled from the deployment INFO is the same for both deployment iNFOS so when I did this process I found everything already.
