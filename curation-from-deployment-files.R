##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: October 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#trying to do a different curation spreadsheet, using existing deployment info spreadsheets

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
install.packages('tidyverse')
library("tidyverse")
#cleaning strings is now a thing
library("stringi")
# # create a dataframe of deployments on drives, modelled on the deploymentInfo.csv from ax70.
## test clean deployment dfs ------------------------
    #This works
    drive81Deploys <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    view(drive81Deploys)
    #the challenge is definitely that thats just, ugly.
    #some of that information, matches the folder structure? coincidence?
    
    #make a clean deployment dataframe
    clean81deploy <- drive81Deploys[6:13,2:71]
    view(clean81deploy)
    
    #with nice and useful col names
    freqpoints <- drive81Deploys[5,2:48]
    head(freqpoints)
    x <- clean81deploy[1,1:23]
    x
    x <- c(x,freqpoints)
    ?colnames
    colnames(clean81deploy) <-x
    
    #look at it? it had two headders
    #fill back in some of the information, will this all be necessary to keep? seems like not
    clean81deploy[-1,]
    view(clean81deploy)
    clean81deploy$clientID <-  "fw"
    clean81deploy$region <-  "Chuckchi"
    clean81deploy$season <- "2013 overwinter"
    clean81deploy <- as.data.frame(clean81deploy[-1,])
    
    #as a repeatable loop
    
    deployCol <- as.character(c("recorderId", "recorderMake","recorderVersion","stationId","hydrophoneId","hydrophoneMake","sampleRate","channels","bitsPerSample","fileStructure","startDate","startTime","driveNo","latitude","longitude","meters","dropDate","dropTime","recoveryDate","recoveryTime","vPerBit","sensitivity","sensitivityFrequencyPoint","1.6","3.2","6.4","12.8","25.6","51.2","100","200","300","400","500","600","700","800","900","1000","1200","1300","1400","1500","2000","2500","3000","3500","4000","4500","5000","5500","6000","6500","7000","7500","8000","16000","32000","40000","50000","60000","70000","80000","90000","1e+05","120000","140000","160000","180000","2e+05"))
    
    ?colnames
    ?read.table()
    #This works
    drive81Deploys <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    
    #The problem had been using 'fill=T' in read.table(), it was making the number of cols misread.
    #the comment character was '#', so it was reading lines 1 AND 6 as comments, thus leaving them out of the final dataframe. #tricky tricky
    #How can I get all the csvs into one table?
    #if it's all in the working directory
    dat =NULL
    deployDF <- NULL
    setwd("~/Documents/R-over-shell-drives/CSV-copied/")
    files <- list.files("~/Documents/R-over-shell-drives/CSV-copied/", pattern="*.csv")
    for (f in files){
      dat <- read.table(f, skip=6, 
                        header=F, sep="," ,
                        blank.lines.skip = FALSE, comment.char="", colClasses = c("character","character", "character")) #read table
      #seems like, there's not a good way right away to preserve the 3 values in that row weirdness
      head(dat)
      deployDF <- dplyr::bind_rows(deployDF, dat)
    } #loop finally working!
    #but now I need to add to it - there's two sets of frequency points
    view(deployDF)
    #can I subset to exactly those variables reliably?
    #I'm going to look at each deployment df seperately
    files
    drive81Deploy2013 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    #get extra info
    year13clientid <- as.character(drive81Deploy2013[3,2])
    year13region<- as.character(drive81Deploy2013[3,3])
    year13period <- as.character(drive81Deploy2013[3,4])
    year13FreqPoints <- (drive81Deploy2013[5,2:(length(drive81Deploy2013))])
    year13FreqPoints <-
      year13FreqPoints %>% discard(is.na) %>% as.character()
    
    #trim dataframe
    drive81Deploy2013 <- drive81Deploy2013 %>% slice(-c(1:4))
    #that, took off the header row too, but that's ok, I'm going to build that list separate
    tmp <- drive81Deploy2009[6,-c(1)]
    tmp <- tmp %>% discard(is.na) %>% as.character() %>% head(-1)
    tmp
    deploy13header <- c(tmp, year13FreqPoints)
    deploy13header
    #glue it onto the dataframe
    colnames(drive81Deploy2013) <- deploy13header
    drive81Deploy2013 <- add_column(drive81Deploy2013, .before="recorderId", client=year13clientid,region=year13region,period=year13period)
    view(drive81Deploy2013)
    #Is this now, the way I want it too? I think so
    
    #So what I want is a loop that does all that automatically
    #and then a match and fill script that uses this dataframe, and the dataframe of the actual info, into a joint dataframe
    #and that's the real curation dataframe?
    
    drive81Deploy2009 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OW09.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    
    #I somehow need to load this one by skipping the lines that imply the #of cols, because otherwise the data gets stacked onto eachother in a very ugly manner
    drive81Deploy2014 <- read.delim("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-SU14.csv", 
                                    header=F, sep="," ,
                                    blank.lines.skip = FALSE, comment.char="", 
                                    col.names=1:71
                                    )
    #rdocs seems to suggest getting length with count.fields before
    wideness <- count.fields("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-SU14.csv",sep=",",
                             skip=5, comment.char = "",blank.lines.skip = FALSE)
    max(wideness)

#alrighty, that variable will hold how many cols i must import when importing deploy csvs
#rather than do these by hand, let me see if I can automate everything I just did

## loop 1 - get a list of dataframe for the csvs--------------
#above is a loop that can do a read file to datafrom from wd, worked well as just that function
setwd("~/Documents/R-over-shell-drives/CSV-copied/")

files <- list.files("~/Documents/R-over-shell-drives/CSV-copied/", pattern="*.csv")

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
  nam <- paste("deployDF", i, sep = "_")
  print(nam)
  assign(nam, dat)
  #make a list to iterate through
  testlst[[i]] <- nam
  i <- i+1
}
#that list isn't what I want, but this is:
deploydflst <- lapply(testlst, get)

#clean up what I don't need from that loop
rm(wideness, dat, nam,f)

# # Loop 2, make the ugly dataframes clean deployment dataframes ---------------------------------------
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


#Clean up my environmentafter that loop
rm(freqPoints, files, hdr, i, nam, tmp, wideness, f, clientid, region, period)
rm(thing, dat, testlst, deploydflst)
rm(cleandeployDFslist, deployDF_1, deployDF_2, deployDF_3)
## test find filepath for cleandeploymentDF[value] match using target folder which is named for the station (usually?)-------- This is for another code script.

#OK. So, what I want now, is, a spreadsheet that uses the recorderID and station ID from deploy df, to find the .wav file in wavsdf, and with the matching, make a curation df that lists the info from the relevant row in deploy df (will repeat alot), the wav file path, and file name, and still need to do, calculated values in there like total volume, or just maybe, size of that file, 
#the subdirectories are in fact a hot mess in ax81.
#find an exact match of instance in wavs file list, of recorderID and station ID from deployment df

str_which(df_wavs81[,1], regex(pattern=recorderID, ignore_case = TRUE))
?regex
#the trick so far is definitely trying to get the regex to register I want there to be 2 patterns matched


###Again, make it happen


