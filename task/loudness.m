function [key,ResponseTime] = loudness(w,option1,option2,option3,escape)    

txtColor = [0 0 0]; % black text

txtLouder   = '\n\n\n\nLouder';
txtQuieter  = '\n\n\n\nQuieter';
txtSame     = '\n\n\n\nSame';
txt         = 'Was the TARGET tone Louder, Quiter or the Same as the STANDARD tone?';

[xCenter,yCenter]   = Screen('WindowSize',w); 
xCenter     = xCenter/2;
yCenter     = yCenter/2;

    DrawFormattedText(w,txt,'center','center',txtColor);    
    DrawFormattedText(w,txtLouder,xCenter-400,'center',txtColor);
    DrawFormattedText(w,txtQuieter,xCenter+200,'center',txtColor);
    DrawFormattedText(w,txtSame,'center','center',txtColor);
    
Screen('Flip', w);

WaitSecs(1);

key=0;
ResponseTime=-Inf;
timeout = Inf;
acceptkeysidx = [option1; option2; option3];

  while(ResponseTime<=0 && GetSecs() < timeout )
      [keyPressed, thisResponseTime, keyCode] = KbCheck;
      if keyPressed && keyCode(escape)
          cleanup;
          error('The participant ended the experiment');
      elseif keyPressed && any( keyCode(acceptkeysidx)  )
         ResponseTime=thisResponseTime;

         %NB! we only pick the first (in order of acceptkeys)
         % if subject is holding down more than one key, will not record both!
         % will warn to screen about mutliple pushes though
         key=find(keyCode(acceptkeysidx) ,1);
         if(nnz(keyCode(acceptkeysidx) ) > 1)
           fprintf('WARNING: multple good button pushes! reporting first button is pushed\n');
         end
      end
  end
end
