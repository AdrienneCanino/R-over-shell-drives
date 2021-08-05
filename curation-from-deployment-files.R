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
# 
# drive.deploy = pd.read_csv("deploymentInfo.csv", names =[drive, recorderId, recorderMake, recorderVersion, stationId, hydrophoneId, hydrophoneMake, sampleRate, channels, bitsPerSample, fileStructure, startDate, startTime, driveNo, latitude, longitude, meters, dropDate, dropTime, recoveryDate, recoveryTime, vPerBit, sensitivity, sensitivityFrequencyPoint, Calibrations for Frequency Points, file volume, file name, file path, preserve])
#in R:
deployCol <- as.character(c("drive", "recorderId", "recorderMake", "recorderVersion", "stationId", "hydrophoneId", "hydrophoneMake", "sampleRate", "channels", "bitsPerSample", "fileStructure", "startDate", "startTime", "driveNo", "latitude", "longitude", "meters", "dropDate", "dropTime", "recoveryDate", "recoveryTime", "vPerBit", "sensitivity", "sensitivityFrequencyPoint", "CalibrationsFrequency Points", "file volume", "file name", "file path", "preserve"))


?read.table()
drive81Deploys <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                             header=F, sep="," ,
                             blank.lines.skip = FALSE, comment.char="")
view(drive81Deploys)

#that didn't work, it's missing the key few rows that are the best functional header in this spreadsheet
#even with options maxed out, lines 1 and 6 in the spreadsheet aren't translating into the dataframe
#The problem had been using 'fill=T' in read.table(), it was making the number of cols misread.
#the comment character was '#', so it was reading lines 1 AND 6 as comments, thus leaving them out of the final dataframe. #tricky tricky



#in Python:
#drive81-deploy = read_csv()


#                            # look through the text inventory for each drive for wav files
#                            # grep sometimes seems to return duplicates though, so the second part is to try and address that. I think it would work.
#                            $ grep ".wav" drive.inv.txt | sort -u > drive.wavs
#                            
#                            # for each wav file found, add a row to the wav table
#                            
# assumes a structure like 'deploymentInfo.csv' on ax70 
#                            # also, this is a a slightly different approach than what I descried on the call 
#                            for wav in drive.wavs:
#                              recorder_id = find code between penultimate and last "/"
#                            station_id = find value between penultimate and antepenultimate "/"
#                            open drive.deploymentInfo.csv as drive.df
#                            copy row where station_id == drive.df[stationId] AND recorder_id == drive.df[recorderId]
#                            append row to drive.deploy
#                            drive.df.loc[new row, 'file path'] = wav
#                            drive.df.loc[row, 'file name'] = wav[find(last "/")+1:] to 
#                            
#                            # I think this should give us a dataframe with all that contextual info for each wav file from each deployment. 
#                            # That might not be the best way to go though. Maybe we do want to keep the authoritative deployment doc(s) separate from the wav inventory. 
#                            

#OK, I think I get it,but I also think it's not going to work consistently because the subdirectories are in fact a hot mess in ax81.
#but something very near it could work, using the value for recorder_id to search the text file

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
clean81deploy[-1,]
clean81deploy$clientID <-  "fw"
clean81deploy$region <-  "Chuckchi"
clean81deploy$season <- "2013 overwinter"
clean81deploy <- as.data.frame(clean81deploy[-1,])

#OK. So, what I want now, is, a spreadsheet that uses the recorderID and station ID from deploy df, to find the .wav file in wavsdf, and with the matching, make a curation df that lists the info from the relevant row in deploy df (will repeat alot), the wav file path, and file name, and still need to do, calculated values in there like total volume, or just maybe, size of that file, 


#setup an empty dataframe
curatedf = data.frame()

#find an exact match of instance in wavs file list, of recorderID and station ID from deployment df

recorderID <- clean81deploy$recorderId[1]
stationID <-  clean81deploy$stationId[1]
recorderID

str_which(df_wavs81[,1], regex(pattern=recorderID, ignore_case = TRUE))
?regex
#the trick so far is definitely trying to get the regex to register I want there to be 2 patterns matched

