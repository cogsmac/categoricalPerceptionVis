%  Presented after a set of trials to encourage the participant to take a
%  break and continue trying hard
%
function blockTextAdjustment(screenDimension, windowPtr, keyboardPtr, remainingTime, cumlatedPoints)
%
%  Author: Caitlyn McColeman
%  Date Created: March 27 18
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: ratio3
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

ln1 = 'Great work! Take a quick break.';
ln2 = ['About ' num2str(remainingTime) ' minutes remaining.' ];
ln3 = ['You have earned ' num2str(cumlatedPoints) '!' ];
ln4 = ['Do you think you can get ' num2str(cumlatedPoints/remainingTime) ' more points today?'];
lnEnd = 'Press the spacebar when you are ready to try!';

% Horizontally and vertically centered:
[nx, ny, textbounds, wordbounds] = DrawFormattedText(windowPtr, ln1, 'center', 'center', 0);
DrawFormattedText(windowPtr, ln2, 'center', 1*(screenDimension(2)/5), 0);
DrawFormattedText(windowPtr, ln3, 'center', 2*(screenDimension(2)/5), 0);
DrawFormattedText(windowPtr, ln4, 'center', 3.5*(screenDimension(2)/5), 0);
DrawFormattedText(windowPtr, lnEnd, 'center', 4.5*(screenDimension(2)/5), 0);

Screen('Flip', windowPtr)

spaceBarHit=0;
% listen to keyboard and wait until participant presses spacebar.
while ~spaceBarHit
    [~, ~, keycode,~] = KbCheck(keyboardPtr);
    
    WaitSecs(.003) % give it a millisecond to keep from melting down.
    spaceBarHit = strcmpi('space', KbName(find(keycode)));
end
display(find(keycode))