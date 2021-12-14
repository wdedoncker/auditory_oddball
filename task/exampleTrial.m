function exampleTrial(w,type, tone, toneName, targetKey)
   correctTxt='Great!';
   wrongTxt='Try Again';

   info.correct=0;
   while(~info.correct)
      fixation(w,[]);
      info=runTrial(toneName,type,tone,targetKey,GetSecs(),GetSecs()+2,...
          [],[],[],[],[],[],[],[],[]);
      if(~info.correct) 
        drawAndKeyInstructions(w,wrongTxt);
      else
        drawAndKeyInstructions(w,correctTxt);
      end
   end
end

function drawAndKeyInstructions(w,txt)
 %% display text
 txtColor=[0 0 0]; % rgb: black
 DrawFormattedText(w, txt, 'center','center', txtColor);
 % "flip" what we've drawn onto the display
 Screen('Flip', w);
 % wait 300 seconds, then advance after keypress
 WaitSecs(1);
end
