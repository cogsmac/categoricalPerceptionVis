%  Show a motivating message, and hang on until the participant is ready to
%  advance.
%
function blockText(screenDimension, windowPtr, keyboardPtr, remainingTime)
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
Screen('FillRect', windowPtr, [1 1 1 ]);

ln1 = 'Great work! Take a quick break.';
ln2 = ['About ' num2str(remainingTime) ' minutes remaining.' ];
lnEnd = 'Press the spacebar when you are ready to continue.';

% Horizontally and vertically centered:
[nx, ny, textbounds, wordbounds] = DrawFormattedText(windowPtr, ln1, 'center', 'center', 0);
DrawFormattedText(windowPtr, ln2, 'center', 1*(screenDimension(2)/3), 0);
DrawFormattedText(windowPtr, lnEnd, 'center', 2*(screenDimension(2)/3), 0);

Screen('Flip', windowPtr)

spaceBarHit=0;
% listen to keyboard and wait until participant presses spacebar.
while ~spaceBarHit
    [~, ~, keycode,~] = KbCheck(keyboardPtr);
    
    WaitSecs(.003) % give it a millisecond to keep from melting down.
    spaceBarHit = strcmpi('space', KbName(find(keycode)));
end
display(find(keycode))
