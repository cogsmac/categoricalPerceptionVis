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

library(data.table)
library(ggplot2)
library(plyr)
library(ez)

currDir = dirname(sys.frame(1)$ofile) # remember where we came from so we can save plots to the appropriate spot
#setwd('../../ratioFits_Data') 

# get names of files
all.files <- list.files(pattern = "trialLvl.txt")

# load data, organize it into meaningful columns
fullDataSet <- lapply(all.files, read.table, sep="\t", header = TRUE, fill = TRUE)
dTableShaped <- rbindlist(fullDataSet)

setkey(dTableShaped , participantID, trialID)
dTableShaped[ is.na(dTableShaped) ] <- NA # replace MATLAB NaN with R-friendly NA 
dTableShaped$participantID<-as.factor(dTableShaped$participantID)
# split the data up into task type by the time task type is available 
tasksIn = unique(dTableShaped$comparisonTask)
barGraph = dTableShaped[dTableShaped$comparisonTask == tasksIn[1],]
barOnly = dTableShaped[dTableShaped$comparisonTask == tasksIn[2],]

## visualize the development of the final estimated values by trial 
bgOut = ggplot(barGraph, aes(x=trialID, y=estimatedThreshold, colour=participantID)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1, alpha = .3) +
  geom_point(size = .5, alpha = .5) + 
  facet_wrap(~testedRatio, nrow = 6) +
  theme_light() + 
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(colour="grey", fill="#E0E0E0"),
        panel.border = element_rect(colour = "black")) # leave facet titles for my pre-decision; make another version and label w graphs


barOnlyOut = ggplot(barOnly, aes(x=trialID, y=estimatedThreshold, colour=participantID)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1, alpha = .3) +
  geom_point(size = .5, alpha = .5) + 
  facet_wrap(~testedRatio, nrow = 6) +
  theme_light() + 
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(colour="grey", fill="#E0E0E0"),
        panel.border = element_rect(colour = "black")) # leave facet titles for my pre-decision; make another version and label w graphs

# this user function will take the subset of data that are of interest ('barGraph' type or 'barOnly' type) and spit out an ANOVA and a couple of graphs
statsAndGraphs <- function(stimulusSubset){
  
  ## look at the one that really matters: the last threshold estimate and its standard deviation
  sameOrDiff = sort(unique(stimulusSubset$sameOrDiffTrial))
  lastEstIdentifier = aggregate(trialID ~ participantID + testedRatio, stimulusSubset[stimulusSubset$sameOrDiffTrial == sameOrDiff[1],], max) # find the participant ID, the ratio and the trial in question (corresponds to last threshold est.)
  sizeCriticalTrials = dim(lastEstIdentifier)
  
  # intialize a dataframe to store all this sweet data
  formalAnalysisTable  <- data.table(
    btwnSubCond = character(),
    participantID = character(),
    testedRatio = character(),
    trialID = integer(),
    estimatedThreshold = numeric(),
    estThresholdStDev = numeric())
  
  for (i in 1:sizeCriticalTrials[1]){
    # use the index to find the estimated threshold and standard deviation
    subIDFilter = stimulusSubset$participantID == lastEstIdentifier[i,1]
    withinCondFilter = stimulusSubset$testedRatio == lastEstIdentifier[i,2]
    trialIDFilter = stimulusSubset$trialID == lastEstIdentifier[i,3]
    
    rowOfInterest = which(subIDFilter & withinCondFilter & trialIDFilter) # returns on number, the row we use to index
    
    estimatedThreshold = stimulusSubset$estimatedThreshold[rowOfInterest]
    estThresholdStDev = stimulusSubset$estThresholdSD[rowOfInterest]
    
    btwnSubCond = stimulusSubset$comparisonTask[rowOfInterest]
    
    # the union of those filters will give us the exact row number to snag the data
    formalAnalysisTable = rbind(formalAnalysisTable, cbind(btwnSubCond, lastEstIdentifier[i,1:3], estimatedThreshold, estThresholdStDev), fill = T)
  }
  
  # run an ANOVA
  basicAOV <- ezANOVA(
    data = formalAnalysisTable
    , dv = .(estimatedThreshold)
    , wid = .(participantID)
    , within = .(testedRatio)
  )
  
  # plot the results [TODO - reorder the ratios for more sensible comparison ]
  group_plot_data = ezPlot(
    data = formalAnalysisTable
    , dv = .(estimatedThreshold)
    , wid = .(participantID)
    , within = .(testedRatio)
    , x = .(testedRatio)
    , split = .(testedRatio)
  )
  
  # output anova object
  list(ezAOVOut = basicAOV, dataIn = formalAnalysisTable, imgToPrint = group_plot_data)
  
  # post hoc tests [forthcoming. need to be very cautious here]
}


# call that function
barGraphOut = statsAndGraphs(barGraph)
 barOnlyOut = statsAndGraphs(barOnly)
