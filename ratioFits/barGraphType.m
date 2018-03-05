%  Prepares the information necessary to draw the bar graph type stimuli
%
%  Author: Caitlyn McColeman
%  Date Created: February 27 2018
%  Last Edit: [Last Time of Edit]
%
function [rectangleData, heightData]=barGraphType(ratioValues, position, screenDimensions, stimType, referenceBarIdx)
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: ratio1
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:


% call function to get stimulus size, position, properties of
% the changing, thresholded stimlus
[rectangleData1, rectangleData2, height1, height2] = ratio1StimulusVals(ratioValues, {'position', position}, screenDimensions, position, stimType, referenceBarIdx);

rectangleData = [rectangleData1', rectangleData2'];
heightData = [height1 height2];
