#trying to do a different curation spreadsheet


# # create a dataframe of deployments on drives, modelled on the deploymentInfo.csv from ax70.
# 
# drive.deploy = pd.read_csv("deploymentInfo.csv", names =[drive, recorderId, recorderMake, recorderVersion, stationId, hydrophoneId, hydrophoneMake, sampleRate, channels, bitsPerSample, fileStructure, startDate, startTime, driveNo, latitude, longitude, meters, dropDate, dropTime, recoveryDate, recoveryTime, vPerBit, sensitivity, sensitivityFrequencyPoint, Calibrations for Frequency Points, file volume, file name, file path, preserve]
#                            
#                            # look through the text inventory for each drive for wav files
#                            # grep sometimes seems to return duplicates though, so the second part is to try and address that. I think it would work.
#                            $ grep ".wav" drive.inv.txt | sort -u > drive.wavs
#                            
#                            # for each wav file found, add a row to the wav table
#                            # assumes a structure like 'deploymentInfo.csv' on ax70 
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