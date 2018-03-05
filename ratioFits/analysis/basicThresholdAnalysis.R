#  Author: Caitlyn McColeman
#  Date Created: March 5 2018
#  Last Edit: 
#
#  Visual Thinking Lab, Northwestern University
#  Originally Created For: ratio1
#
#  Reviewed: []
#  Verified: []
#
#  INPUT: subID, integer; the identifer for this participant
#
#  OUTPUT: saves .mat & .txt files to current directory
#
#  Additional Comments:
#       Broadly, the workflow is
#           1) set stimulus values
#           2) present stimuli
#           3) record accuracy
#           4) adjust staircase
#           5) terminate upon meeting threshold/timing out
#           6) save data
#
#  Additional Scripts Used:
#           1) Quest package (distributed via psychtoolbox) TODO: add
#                   citations
#           2) ratio1StimulusVals.m

#install.packages('data.table')
library(data.table)
library(ggplot2)

currDir = dirname(sys.frame(1)$ofile) # remember where we came from so we can save plots to the appropriate spot
setwd('../../ratioFits_Data') 

# get names of files
all.files <- list.files(pattern = "trialLvl.txt")

# load data, organize it into meaningful columns
fullDataSet <- lapply(all.files, read.table, sep="\t", header = TRUE, fill = TRUE)
dTableShaped <- rbindlist(fullDataSet)

setkey(dTableShaped , participantID, trialID)
dTableShaped[ is.na(dTableShaped) ] <- NA # replace MATLAB NaN with R-friendly NA 

ggplot(dTableShaped, aes(x=trialID, y=estimatedThreshold, colour=testedRatio)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1) +
  geom_point() + 
  facet_wrap(~testedRatio, nrow = 6)

