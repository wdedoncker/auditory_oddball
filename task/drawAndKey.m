function drawAndKey(w,txt)
 %% display text
 txtColor=[0 0 0]; % rgb: black
 txt=[txt '\n\nPush any key'];
 DrawFormattedText(w, txt, 'center','center', txtColor);
 % "flip" what we've drawn onto the display
 Screen('Flip', w);
 % wait 300 seconds, then advance after keypress
 WaitSecs(.3);
 KbWait();
end
