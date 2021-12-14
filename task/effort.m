function [key,ResponseTime] = effort(w,option1,option2,option3,escape)    

txtColor = [0 0 0]; % black text

txtLouder   = '\n\nVery Hard';
txtQuieter  = '\n\nVery Easy';
txtSame     = '\n\nModerate';
txt         = 'How Effortful did you find this block?';

location = randi(2);
if location == 1
    DrawFormattedText(w,txt,'center','center',txtColor);
    DrawFormattedText(w,txtLouder,'center','center',txtColor);
    DrawFormattedText(w,txtQuieter,'center','center',txtColor);
    DrawFormattedText(w,txtSame,'center','center',txtColor);
elseif location == 2
    DrawFormattedText(w,txt,'center','center',txtColor);    
    DrawFormattedText(w,txtLouder,'center','center',txtColor);
    DrawFormattedText(w,txtQuieter,'center','center',txtColor);
    DrawFormattedText(w,txtSame,'center','center',txtColor);
end    
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
