function onset=fixation(w,when)
   oldSize = Screen('TextSize',w, 96);
   DrawFormattedText(w,'+','center','center', [255 255 255]);
   onset=Screen('Flip', w,when);
   Screen('TextSize',w, oldSize);
end
