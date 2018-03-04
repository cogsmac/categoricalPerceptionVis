%  Ending out the experiment and intro to debrief
%  
function exitText(screenDimension, windowPtr)
% 
%  Author: Caitlyn McColeman
%  Date Created: [Date of Creation] 
%  Last Edit: March 4 2018
%  
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: ratio1
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: 
%  
%  OUTPUT: 
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 

Screen('FillRect', windowPtr, [1 1 1 ]);

ln1 = 'Way to go! You are all done.';
ln2 = 'Please exit the room and let Caitlyn know that you have completed the study.';

% Horizontally and vertically centered:
[nx, ny, textbounds, wordbounds] = DrawFormattedText(windowPtr, ln1, 'center', 'center', 0);
DrawFormattedText(windowPtr, ln2, 'center', 2*(screenDimension(2)/3), 0);


Screen('Flip', windowPtr)
