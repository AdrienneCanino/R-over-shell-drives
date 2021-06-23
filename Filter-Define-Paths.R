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
?str_which()

#Can't take the whole dataframe, so let's do, subdirectory10
#this might have to get looped somehow, like do subdirectory 4-10 with the same method
str_which(df_AX81$subdirectory10, regex(".csv$", ignore_case=TRUE, ))
#returns "integer(0)" so... there's nothing there?
#nothing in 9 , 8, 7
str_which(df_AX81$subdirectory6, regex(".csv$", ignore_case=TRUE, ))
# 2010 2027 2044 2061 2078 2095 2112 2129 8150 8243 8251 8259 8267 8275 8283 8291

str_which(df_AX81$path, regex(".csv$", ignore_case=TRUE, ))
#and, nothing  in any of the other locations, so. Let's see if this work the way I wanted


df_AX81$subdirectory6[2010,]
# "deploymentInfo.csv" , so, yeah, that's what I wanted. Now for the whole, row of values
#so the csvs are in subdirectory3

df_AX81[2010,]
#so that's the directory, how do I get that as a string?
?toString
?unite
unite(df_AX81, col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

#this did what I wanted, let's save that output


df_ax81 <- unite(df_AX81, col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

#so now I have the dataframe with the subdirectories as cols and a col for the pathname as a whole string

#That was kind of a sidebar, what I still want is, all the csvs, which I have those index numbers now.
#so I should be able to output, the path col value, where those index are, right?

#ok first make the object holding the index values
csvs_index81 <-c(2010, 2027, 2044, 2061, 2078, 2095, 2112, 2112, 2129, 8150, 8243, 8251, 8259, 8267, 8275, 8283, 8291)

df_ax81$file_path[csvs_index81]

#hooray!

#Let's do the same for WAVs

str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))

#Whoa, that's a lot, is it right?

df_ax81$file_path[2480]
#hmm,  "mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40/F42C1113.WAV"
df_ax81$file_path[1808]
#yep, "mnt/shell/ax81/Shell Shallow Hazards 2013/AMAR D 216 - 2nd deployment/16BitChannel9/AMAR 216.424.Chan_9-16bps.1374976743.2013-07-28-01-59-03.wav"
#yikes that's an ugly pathname

wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))

length(wavs_index81)
#so 13334 wav files, but I knew that?
#make dataframe of all the wavs files
df_wavs81 <-df_ax81[wavs_index81,]

#find the groupings of those
#I have to not only group, but then do another dplyr thing to the grouped df
#so, summarise?
#by count

df_wavs81 %>%
  group_by(subdirectory3) %>%
  summarise(n=n())

#Yes!  A tibble: 3 x 2
# subdirectory3                  n
# <fct>                      <int>
#   1 fw                          7154
# 2 shell                       5988
# 3 Shell Shallow Hazards 2013   192

#so most of the wave files are in fw, I think I'll need more information than that

df_wavs81$subdirectory4 <- as_factor(df_wavs81$subdirectory4)
levels(df_wavs81$subdirectory4)
#2? really? I have much distrust. Yeah, totally not, I did something wrong there.
#so a good place to call it for today.

