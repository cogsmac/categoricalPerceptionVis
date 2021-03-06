#  Author: Caitlyn McColeman
#  Date Created: March 5 2018
#  Last Edit: Apr 11; aesthetic updates
#
#  Visual Thinking Lab, Northwestern University
#  Originally Created For: ratio1
#
#  Reviewed: []
#  Verified: []
#
#  INPUT: 
#
#  OUTPUT: 
#
#  Additional Comments:
#     updated Mar 22 to work with ratio2 instead of ratio1
#
#  Additional Scripts Used:

library(data.table)
library(ggplot2)
library(plyr)
library(ez)

expName = 'ratio2'
wdName = '../ratioFits_data2'

currDir = dirname(sys.frame(1)$ofile) # remember where we came from so we can save plots to the appropriate spot
setwd(wdName) 

# get names of files
all.files <- list.files(pattern = "trialLvl.txt")

# load data, organize it into meaningful columns
fullDataSet <- lapply(all.files, read.table, sep="\t", header = TRUE, fill = T, fileEncoding="US-ASCII")
dTableShaped <- rbindlist(fullDataSet, 'fill' = T)

# the automatic order of the testedRatio doesn't make much sense. Reorder them so comparison is easier. 
if ('ratio2' == expName){
dTableShaped$testedRatio = factor(dTableShaped$testedRatio,levels(dTableShaped$testedRatio)[c(1,7,14,6,
                                                                                              3,9,2,8,
                                                                                              4,19,15,10,
                                                                                              5,12,16,11,
                                                                                              18,13,17,20)])
} else if ('ratio1' == expName)
{
  dTableShaped$testedRatio = factor(dTableShaped$testedRatio)
}
setkey(dTableShaped , participantID, trialID)
dTableShaped[ is.na(dTableShaped) ] <- NA # replace MATLAB NaN with R-friendly NA 
dTableShaped$participantID<-as.factor(dTableShaped$participantID)

# split the data up into task type by the time task type is available 
tasksIn = unique(dTableShaped$comparisonTask)
barGraph = dTableShaped[dTableShaped$comparisonTask == tasksIn[1],]
barOnly = dTableShaped[dTableShaped$comparisonTask == tasksIn[2],]
stkOnly = dTableShaped[dTableShaped$comparisonTask == tasksIn[3],]

## visualize the development of the final estimated values by trial 
bgOut = ggplot(barGraph, aes(x=trialID, y=estimatedThreshold, colour=participantID)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1, alpha = .3) +
  geom_point(size = .5, alpha = .5) + 
  facet_wrap(~testedRatio, nrow = 5) +
  theme_light() + 
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(colour="black", fill="#E0E0E0"),
        panel.border = element_rect(colour = "black"))+
        theme(strip.text = element_text(colour = 'black')) # leave facet titles for my pre-decision; make another version and label w graphs


barOnlyOut = ggplot(barOnly, aes(x=trialID, y=estimatedThreshold, colour=participantID)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1, alpha = .3) +
  geom_point(size = .5, alpha = .5) + 
  facet_wrap(~testedRatio, nrow = 6) +
  theme_light() + 
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(colour="grey", fill="#606060"),
        panel.border = element_rect(colour = "black")) # leave facet titles for my pre-decision; make another version and label w graphs

stkOnlyOut = ggplot(stkOnly, aes(x=trialID, y=estimatedThreshold, colour=participantID)) + 
  geom_errorbar(aes(ymin=estimatedThreshold-estThresholdSD, ymax=estimatedThreshold+estThresholdSD), width=.1, alpha = .3) +
  geom_point(size = .5, alpha = .5) + 
  facet_wrap(~testedRatio, nrow = 6) +
  theme_light() + 
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(colour="grey", fill="#606060"),
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
barGraphAllOut = statsAndGraphs(barGraph)
 barOnlyAllOut = statsAndGraphs(barOnly)
 
fullSet = rbind(barGraphAllOut$dataIn, barOnlyAllOut$dataIn) # only keep the header once
fullSet = as.data.frame(fullSet) # coerce to data frame to use its snazzy aggregator 

summaryRatio1 <- aggregate(x = fullSet$estimatedThreshold, 
                               by = list(testedRatio = fullSet$testedRatio, fullSet$btwnSubCond), 
                               FUN = mean)

names(summaryRatio1) = c('testedRatio', 'stimulus', 'mean')

summaryRatio1$mean = exp(summaryRatio1$mean)

standardDevs <-  aggregate(x = fullSet$estThresholdStDev, 
                           by = list(testedRatio = fullSet$testedRatio, fullSet$btwnSubCond), 
                           FUN = mean)
names(standardDevs) = c('testRatioSD', 'stimType', 'SD')

summaryRatio1 <- cbind(summaryRatio1, standardDevs) # add the standard deviations to the data 

conditionsIn  = unique(fullSet$btwnSubCond)

# plot the data summary
ratio1Pilot = ggplot() + 
   geom_point(data = summaryRatio1[summaryRatio1$stimulus== conditionsIn[1],], aes(x=testedRatio, y = mean), size = 5, alpha = .5, colour = "purple") + 
   geom_point(data = summaryRatio1[summaryRatio1$stimulus== conditionsIn[2],], aes(x=testedRatio, y = mean), size = 5, alpha = .5, colour = "#228B22") + 
   #geom_errorbar(data = summaryRatio1, aes(x=testedRatio, ymin=mean-SD, ymax=mean+SD), width=1, alpha = .3) +
   geom_point(data = fullSet[fullSet$btwnSubCond == conditionsIn[1],], aes(x=testedRatio, y = exp(estimatedThreshold)), size = 2, alpha = .1, colour = "purple") +
   geom_point(data = fullSet[fullSet$btwnSubCond == conditionsIn[2],], aes(x=testedRatio, y = exp(estimatedThreshold)), size = 2, alpha = .1, colour = "#228B22") +
   facet_wrap(~stimulus, nrow = 1) +
   theme_light() + 
   theme(panel.grid.minor = element_blank(),
         strip.background = element_rect(colour="grey", fill="#E0E0E0"),
         panel.border = element_rect(colour = "black")) # leave facet titles for my pre-decision; make another version and label w graphs
