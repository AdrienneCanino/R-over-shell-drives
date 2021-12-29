# R-over-shell-drives
Now we need to curate the data into datasets for archiving

# Goal: Get through 59 hard drives worth of semi-organized files: audio, csv, excel, pdfs - mostly, and know, sort of, what is where in them. 

## Summary to Date:
December 29, 2021
### do-it-all type scripts
`do-it-all-take-one.R` does:

* Takes a specific path to a specific drive in the new.invs, and uses loops to:
    - pull the file paths to CSVs out
    - (A step here not in the script - go to `mnt/shell` and get those csvs)
    - look at those csvs in the CSVs-copied directory
    - clean the csvs into proper dfs with all their freq points and descriptive info in place
    - write out the clean deploy dfs
    - write out the file paths to wav files
    - find the deployment period, use that string match to find wav files related to that deployment
    - write a list of those wavs' file paths

* It's very manual, but doesn't take too long, maybe 1-2 hours, for the whole process, 
    - The next step is for Chris to experiment with that list of wav file paths to ~get~ _copy_ those files out of the `/mnt/shell`

`do-it-all-take-two.R` does:

* uses a .txt list of drives, from the google spreadsheet of wav/csv count, to make a list of drive names
* uses loops to go through each of those drives and more automatically complete the tasks of `do-it-all-take-one.R`
* Tries to at least

### old, figure-it-out scripts

`Explore-Access_text.R` does:

* makes the text file from the /mnt/shell export a dataframe

* does some counting of how many files in select folders

`Filter-Define-Paths.R` does:

* I can get a dataframe of certain file types

* I can write the file paths out to a txt file (much usefulness in bash script that makes a copy of our final data) 

* that shows the path it exists in, based on the text export of \mnt\shell 

* And can spit out a table that counts them up grouped by subdirectory 

** chosen subdirectory is a bit, indurable, because it is hardcoded, but I think can be made re-usable script

`count-copy-count_wholeBunches.R` does:

* Builds an index object to subset the text dataframe based on file ending (eg, .wav)

* unsuccessfully tries to pull ‘target folder’ out of the dataframe (where many wavs live would be a target folder)

* gets a set of filepaths in a list that I can count over to count for files

* using a not piped conglomeration of functions that checks a thing against a pattern that I got in a very manual way, and loads it as character data to a list.

** Hrm?

* and now ultimately is looking for where those deployment info csvs live

`Make-Curation-Spreadsheet.R` does:

* this builds a dataframe, with the target info as cols, targeting the information we want in the ultimate curation spreadsheet

* then it loads some information into by hand, from what I learned in other scripts, then tries to load up a bunch automatically

 * that’s it

`curation-from-deployment-files.R` does:

* this is where I build/use a dataframe made from uploading a deploymentInfo.csv from \mnt\shell  (that I did by hand)

* And discover that different deploymentInfo csvs have different #s of cols so it’ll be hard to concat them

* And that some deployInfo csvs did not have a header that I needed (there were 2 headers/badly formated csvs)

* THEN it looks at Chris’s psuedo code for building curation spreadsheet

* and tries a similar take that looks for recorderID in the deployment df, so that it can merge the info of the wavs dataframe to the curation dataframe, 

* which would build a spreadsheet with many rows about each recorderID, but matched to a different wav file in eachrow

`get-mnt-shell-access.R` does:

* this was just me thinking, oh I need to programmatically access \mnt\shell and how do I do that?

* and it got real hard so I did not do

* though, in Ian’s ATN pipelines, there’s an example of Trevor SSH ing, that we could probably build off of
