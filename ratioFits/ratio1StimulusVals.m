%  This function takes stimulus values as input, and draws the bars as
%  output
%
function [stimRect1, stimRect2, heightBar1, heightBar2] =ratio1StimulusVals(...
    presentedRatio, ...
    irrelevantChange, ...
    screenSize, ...
    positionIdx, ...
    stimType, ...
    referenceBarIdx)

%  Author: Caitlyn McColeman
%  Date Created: Feb 26 2018
%  Last Edit:  March 16 2018 
%
%  Visual Thinking Laboratory, Northwestern University
%  Originally Created For: ratio psychophysics experiment
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:
%       presentedRatio, vect; the value of the two items. One is 1; the other
%               is a proportion of the height of the 1 (reference) value.
%       irrelevantChange, cell; the method by which the two presented items
%               are not exactly the same on the screen. Currently accepts
%               {"scale", n} or {"position", m} where n is 0.5-1.5 the size
%               of the original image and m is one of [??] positions.
%       screenSize, matrix; the number of pixels on the current screen.
%               Stimuli are drawn relative to screen size.
%
%  OUTPUT:
%       stimPair1, matrix; the dimensions required to draw the first two
%               rectangles (first stimulus)
%       stimPair2, matrix; the dimensions required to draw the second two
%               rectangles (second stimulus)
%
%  Additional Scripts Used:
%       uses position information hard coded in positionRef.m
%
%  Additional Comments:
%      - default size for a full-size bar is 1/4 of the screen height, 1/16 its width.
%      - added a third condition for ratio2 so we can reuse this code. This
%        is for the stacked bar graph.


rectWidth = screenSize(1)/18;
fullRectHeight = screenSize(2)/5; % so 100% of the ratio is 1/5 the screen

% determine heights of bars
if strcmpi(stimType, 'barGraphType') | strcmpi(stimType, 'stackedType')
    heightBar1 = presentedRatio(1)*fullRectHeight;
    heightBar2 = presentedRatio(2)*fullRectHeight;
elseif strcmpi(stimType, 'barOnlyType')
    heightBar1 = presentedRatio(referenceBarIdx~=1)*fullRectHeight;
    heightBar2 = NaN; % only bar1 is meaningful when one bar is shown at a time
end

% figure out where to centre them
posCenters = positionRef(screenSize); % get the closest ninth

if strcmpi(irrelevantChange{1}, 'position')
    positionIdx = irrelevantChange{2};
else
    positionIdx = 5;
end

if strcmpi(stimType, 'barGraphType')
    % shimmy a bit so the two bars straddle the centroid of this ninth
    x1Bar1 = posCenters(positionIdx, 1)-1.5*(rectWidth); % x dimension
    x2Bar1 = x1Bar1 + rectWidth; % x dimension
    
    x1Bar2 = posCenters(positionIdx, 1)+.5*(rectWidth);
    x2Bar2 = x1Bar2 + rectWidth;
elseif strcmpi(stimType, 'barOnlyType') 
    x1Bar1 = posCenters(positionIdx, 1)-.5*(rectWidth);
    x2Bar1 = x1Bar1 + rectWidth;
    
    x1Bar2 = NaN; x2Bar2 = NaN;
elseif strcmpi(stimType, 'stackedType')
    x1Bar1 = posCenters(positionIdx, 1)-.5*(rectWidth);
    x2Bar1 = x1Bar1 + rectWidth;
    
    x1Bar2 = x1Bar1; x2Bar2 = x2Bar1;
end
if presentedRatio(1)==1 % if the left bar is larger
    y1Bar1 = posCenters(positionIdx, 2)-.5*(heightBar1); % lower value is higher on screen; origin (0, 0) top left
    y2Bar1 = y1Bar1 + heightBar1;
    if strcmpi(stimType, 'barGraphType') | strcmpi(stimType, 'stackedType')
        y1Bar2 = y2Bar1 - heightBar2; % not quite as tall as bar 1
        y2Bar2 = y2Bar1; % positions along aligned scale -- bottoms line up.
    else
        y1Bar2 = NaN;
        y2Bar2 = NaN;
    end
else
    if strcmpi(stimType, 'barGraphType') | strcmpi(stimType, 'stackedType')
        y1Bar2 = posCenters(positionIdx, 2)-.5*(heightBar1); % lower value is higher on screen; origin (0, 0) top left
        y2Bar2 = y1Bar2 + heightBar2;
        
        
        y1Bar1 = y2Bar2 - heightBar1; % not quite as tall as bar 2
        y2Bar1 = y2Bar2; % positions along aligned scale -- bottoms line up.
    else
        y1Bar1 = posCenters(positionIdx, 2)-.5*(heightBar1); % lower value is higher on screen; origin (0, 0) top left
        y2Bar1 = y1Bar1 + heightBar1;
        
        y1Bar2 = NaN; y2Bar2 = NaN;
    end
end

stimRect1 = [x1Bar1, y1Bar1, x2Bar1, y2Bar1];
stimRect2 = [x1Bar2, y1Bar2, x2Bar2, y2Bar2];

