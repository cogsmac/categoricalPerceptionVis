%  This function takes stimulus values as input, and draws the bars as
%  output
%  
function [stimPair1, stimPair2] = ratio1StimulusVals(...
                                  ratioArray, ...
                                  irrelevantChange, ...
                                  screenSize)

%  Author: Caitlyn McColeman
%  Date Created: Feb 26 2018 
%  Last Edit: [Last Time of Edit] 
%  
%  Visual Thinking Laboratory, Northwestern University
%  Originally Created For: ratio psychophysics experiment
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: 
%       ratioArray, vect; the value of the two items. One is 1; the other
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
%       default size for a full-size bar is 1/4 of the screen height, 1/16 its width.


 rectWidth = screenSize(1)/16;
rectHeight = screenSize(2)/4;


stimPair1 = CenterRectOnPointd([0 0 rectWidth rectHeight],...
        x, y);



