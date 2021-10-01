##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: July 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#trying to do a different curation spreadsheet, using existing deployment info spreadsheets

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")

# # create a dataframe of deployments on drives, modelled on the deploymentInfo.csv from ax70.
# test
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
#but now I need to add to it.
view(deployDF)

#this loop worked once, but it didn't continue the loop?
#I'm going to look at each deployment df seperately
files
drive81Deploy2013 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                             header=F, sep="," ,
                             blank.lines.skip = FALSE, comment.char="")

drive81Deploy2009 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OW09.csv", 
                             header=F, sep="," ,
                             blank.lines.skip = FALSE, comment.char="")

drive81Deploy2014 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-SU14.csv", 
                                header=F, sep="," ,
                                blank.lines.skip = FALSE, comment.char="", skip=5)



view(drive81Deploy2014) #this one is loading in with more rows than appropriate ? Fixed now.

#the subdirectories are in fact a hot mess in ax81.

#OK. So, what I want now, is, a spreadsheet that uses the recorderID and station ID from deploy df, to find the .wav file in wavsdf, and with the matching, make a curation df that lists the info from the relevant row in deploy df (will repeat alot), the wav file path, and file name, and still need to do, calculated values in there like total volume, or just maybe, size of that file, 


#setup an empty dataframe
curatedf = data.frame()

#find an exact match of instance in wavs file list, of recorderID and station ID from deployment df

recorderID <- deployDF$recorderId
stationID <-  clean81deploy$stationId[1]
recorderID

str_which(df_wavs81[,1], regex(pattern=recorderID, ignore_case = TRUE))
?regex
#the trick so far is definitely trying to get the regex to register I want there to be 2 patterns matched

