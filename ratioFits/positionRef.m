%  Just so we have a record of it, this is the x, y coordinates around
%  which the initial rectangle in a stimulus may be drawn.
%
function [xCentered, yCentered] = positionRef(screenSize, barWidth)
%
%
%  Author: Caitlyn McColeman 
%  Date Created: February 26 2018
%  Last Edit:  
%  
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: 
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: screenSize, vect; the X and Y limits of the open screen
%         barWidth, dec.; the distance between the two bars as a proportion of the X limit of the scren
%  
%  OUTPUT: An x, y coordinate for the reference bar
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 
%       note that this returns the coordinates of the reference bar. The second
%       bar will have to be draw in relation to it. Mind the leftOrRight
%       value when actually drawing the stimulus
%       This runs ahead of time for a rapid reference to right the
%       position
%       [TO DO write in a scaling option]
%{


% find equal spacing
heightIn = screenSize(2)/3;
widthIn = screenSize(1)/3;

yBoundaries = 0:heightIn/3:screenSize(2); % y dimension
xBoundaries = 0:widthIn/3:screenSize(1); % x dimension 

% loop through boundaries to find centroids
iterY = 0; iterX = 0;

nineCenters = [];
for y = yBoundaries(1:end-1)
    iterY = iterY + 1;
    
    for x = xBoundaries(1:end-1)
        iterX = iterX + 1;
        
        % gets the center of the 1/9th of the screen we're using
        nineCenters = [CenterRectOnPointd([0 0 widthIn heightIn],(x+widthIn)/2,(y+heightIn)/2);
            nineCenters]; 
    end
end
%}

% hard coding for rapid dev.
xCentered = 500;
yCentered = 600;
