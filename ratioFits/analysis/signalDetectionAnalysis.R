#  Author: Caitlyn McColeman
#  Date Created: March 6 2018
#  Last Edit: 
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
#
#  Additional Scripts Used:
#
#
library(data.table)
library(psyphy)
library(lattice)

## organize data
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

## function to calculate hits, false alarms 
sigDetectionPrep <- function(dataIn){
  
  sameOrDiff = sort(unique(dataIn$sameOrDiffTrial)) # alphabetize to get indexing consistent: "different, same" will result
  
  # subset data by correct answer
  diffSubset = dataIn[dataIn$sameOrDiffTrial == sameOrDiff[1],]  # do not match
  sameSubset = dataIn[dataIn$sameOrDiffTrial == sameOrDiff[2],]  # match 
  
  # proportion of hits for same/different trials
  hitPropDiff = mean(diffSubset$response) # 0 is inaccurate, 1 is accurate and these are only "hit" trials... participants need to identify true differences
  hitPropSame = mean(sameSubset$response) # correct rejection                                             ... participants need to identify true matches
  
  # proportion of false alarms for same trials
  FAPropSame = 1 - mean(sameSubset$response) # if they're wrong it's because they said two matching stimuli were different when they were actually the same [false alarm]

  # TODO: subset by proportion tested
  
  
  # output hits, misses, false alarms, and correct rejections 
  list(hit = hitPropDiff, miss = 1-hitPropDiff, falseAlarm = FAPropSame, corrRejection = hitPropSame)
  
  
}


## function to visualize signal detection matrices


# use the function to get the signal detection data for the different datasets 
barGraphSigDetDat = sigDetectionPrep(barGraph)
 barOnlySigDetDat = sigDetectionPrep(barOnly)
  
## visualize in a typical signal detection matrix
 viewSigDetection <- function(sigDetDat){
   
   horizontalLabels = c("detection","rejection")
   verticalLabels = c("truly different", "truly same")
   
   # the matrix to visualize  
   sigDetMat = matrix(c(sigDetDat$hit, sigDetDat$miss, sigDetDat$falseAlarm, sigDetDat$corrRejection), nrow= 2, ncol =2)
   
   # set up color scale
   rgb.palette <- colorRampPalette(c("cyan", "black"), space = "rgb")
   
   # get the image # [TODO: edit the title to reflect the tested ratio]
   #a = levelplot(sigDetMat, main="signal detection performance", xlab="response", ylab="reality", col.regions=rgb.palette(100), cuts=100, at=seq(0,1,0.01))) 
   a = levelplot(sigDetMat, main="signal detection performance", xlab="response", ylab="reality", colorkey = FALSE, col.regions=rgb.palette(100), cuts=100, at=seq(0,1,0.01), scales=list(x=list(at=c(1, 2), labels=c('different', 'same')), y=list(at=c(1, 2), labels=c('same', 'different'))))
   
   print(a) # have to display it to get the viewpoint info
   b = grid.ls(viewport=TRUE, grobs=TRUE)
   
   # round values for presentation
   presMat = round(sigDetMat,2)

  ll <- seekViewport("plot_01.panel.1.1.vp") # get the panel view
  grid.text(toString(presMat[1,1]), x = unit(.25, "npc"), y = unit(.75,"npc"), just = c("center", "center"), gp = gpar(cex=1.6, col = "black")) # top left
  grid.text(toString(presMat[1,2]), x = unit(.75, "npc"), y = unit(.75,"npc"), just = c("center", "center"), gp = gpar(cex=1.6, col = "grey")) # top right
  grid.text(toString(presMat[2,1]), x = unit(.25, "npc"), y = unit(.25,"npc"), just = c("center", "center"), gp = gpar(cex=1.6, col = "grey")) # bottom left
  grid.text(toString(presMat[2,2]), x = unit(.75, "npc"), y = unit(.25,"npc"), just = c("center", "center"), gp = gpar(cex=1.6, col = "black")) # bottom right

   # TODO: subset by proportion tested
   list(a, b)
 }
 
 # use the function to draw signal detection matrices
 graphBarList = viewSigDetection(barGraphSigDetDat)
  barOnlyList = viewSigDetection(barGraphSigDetDat)