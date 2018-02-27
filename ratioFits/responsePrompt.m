%  This is the copy for prompting participant response and reminding them
%  which buttons to use
%
function responsePrompt(screenDimension, windowPtr)
%
%  Author: Caitlyn McColeman
%  Date Created: Feb 27 2018
%  Last Edit:
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

responsePromptText = 'Same or Different?';
buttonReminderSame = 'f';
buttonReminderDiff = 'j';

% Horizontally and vertically centered:
[nx, ny, bbox] = DrawFormattedText(windowPtr, responsePromptText, 'center', 'center', 0);

Screen('DrawText', windowPtr, buttonReminderSame, screenDimension(1)/4,   screenDimension(2)*2/3);
Screen('DrawText', windowPtr, buttonReminderDiff, screenDimension(1)*3/4, screenDimension(2)*2/3);