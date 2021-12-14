function [effort,ResponseTime] = effortVAS(w,rightKey,selectKey,leftKey,escape)    

txtColor = [0 0 0]; % black text
txtHarder   = 'Very Hard';
txtEasier   = 'Very Easy';
txtConfirm  = 'Press the button to confirm';
txt         = 'How Effortful did you find this block?';

[xCenter,yCenter]   = Screen('WindowSize',w); 
xCenter     = xCenter/2;
yCenter     = yCenter/2;
slack       = Screen('GetFlipInterval',w);
flip        = Screen('Flip',w);
baseRect    = [0 0 10 30];
rectColor   = [0 0 0];
pixelsPerPress  = 2.5;
waitframes  = 1;
LineY = yCenter;
LineX = xCenter;

while true
  [keyPressed, thisResponseTime, keyCode] = KbCheck;
  if keyPressed == escape
      cleanup;
  elseif keyPressed && keyCode(leftKey)
      LineX = LineX - pixelsPerPress;
  elseif keyPressed && keyCode(rightKey)
      LineX = LineX + pixelsPerPress;
  elseif keyPressed && keyCode(selectKey)
      effort = ((LineX - xCenter) + 250)/50;
      ResponseTime = thisResponseTime;
      break;
  end
  
    if LineX < (xCenter-250)
        LineX = (xCenter-250);
    elseif LineX > (xCenter+250) 
        LineX = (xCenter+250);
    end
    if LineY < 0
        LineY = 0;
    elseif LineY > (yCenter+10)
        LineY = (yCenter+10);
    end
  
    %% Feedback about slider position
    centeredRect = CenterRectOnPointd(baseRect, LineX, LineY);
    DrawFormattedText(w, txt,'center', (yCenter-150), txtColor);
    DrawFormattedText(w, txtConfirm,'center', (yCenter+150), txtColor);
    Screen('DrawLine', w, [0, 0, 0], (xCenter+250 ), (yCenter), ...
        (xCenter-250), (yCenter), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter+250 ), (yCenter+10),...
        (xCenter+250), (yCenter-10), 1);
     Screen('DrawLine', w, [0, 0, 0], (xCenter+200 ), (yCenter+10),...
        (xCenter+200), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter+150 ), (yCenter+10),...
        (xCenter+150), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter+100 ), (yCenter+10),...
        (xCenter+100), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter+50 ), (yCenter+10),...
        (xCenter+50), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter), (yCenter+10),...
        (xCenter) , (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter-50 ), (yCenter+10),...
        (xCenter-50), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter-100 ), (yCenter+10),...
        (xCenter-100), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter-150 ), (yCenter+10),...
        (xCenter-150), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter-200 ), (yCenter+10),...
        (xCenter-200 ), (yCenter-10), 1);
    Screen('DrawLine', w, [0, 0, 0], (xCenter-250 ), (yCenter+10),...
        (xCenter- 250), (yCenter-10), 1);
    Screen('DrawText', w, txtEasier, (xCenter-400), (yCenter+25),...
        [0, 0, 0]);
    Screen('DrawText', w, txtHarder, (xCenter+200), (yCenter+25),...
        [0, 0, 0]);
    Screen('FillRect', w, rectColor, centeredRect);
    flip = Screen('Flip', w, flip + (waitframes - 0.5) *  slack);        
end
end