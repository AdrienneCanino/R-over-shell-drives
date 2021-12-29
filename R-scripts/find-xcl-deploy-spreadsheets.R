##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: December 2021
#git repo for folder with script, etc
#new.invs too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

##Finding deployment info spreadsheets that are not csvs, but that I want to make into CSV

# 1 - make all the text dummys of the shell drives into dfs with a File_path column I can regex search over
#make sure wd is local git repo
files <- list.files(path="../new.invs")

##create column header for the dfs I'm going to make
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

dat <-  NULL
drives_lst <- NULL

## Loop through to read lines
for(f in files){
  #setup file path for readin
  pth <- capture.output(cat("../new.invs/",f, sep=""))
  print(pth)
  
  #read in the lines to dataframe
  dat <- read.delim(file=pth, sep="/",
                col.names = columnNames, header = FALSE, comment.char="",
                blank.lines.skip=FALSE, fill =TRUE)
  
  #make a context specific name for that DF
  nam <- paste("df", as.character(f), sep = "_")
  print(nam)
  assign(nam, dat)
  
  #make a list of DF names to iterate through
  drives_lst <- append(drives_lst, nam)
  
}

#Turn that list of names into object listing the call-able dataframes
drives_lst<- lapply(drives_lst, get)

## Loop through to make file path columns

i <- 1
path_dfs_lst <- NULL
dat <- NULL
nam <-  NULL

for(thing in drives_lst){

  #re-assign dataframe with united colum
  dat<- 
    as_tibble(drives_lst[[1]])%>% 
    #mutate_all(as.character) %>%
    unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")
  
  dat$file_path <-trimws(dat$file_path, which="right", whitespace="/")
  
  #rename it and list it
  nam <- paste("paths_df", files[i], sep = "_")
  print(nam)
  assign(nam, dat)
  path_dfs_lst <- append(path_dfs_lst, nam)
  
  #iterator
  i <- i+1
  
}
path_dfs_lst <- lapply(path_dfs_lst, get)

#Can I remove the old dataframes?

## 2 - use these path DFs to find excel files
