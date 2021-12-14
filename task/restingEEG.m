
 
%%% Bring up Fixation Cross for resting EEG
 
screenRes   = []; 
% screenRes   = [0 0 800 600]; 
w           = PTBsetup(screenRes);

drawAndKey(w,['We will now record 7 minutes at rest\n\n',...
    'Keep your eyes open, focus on the cross and stay relaxed\n\n',...
    'Ready?']);

fixation(w,[]); 

port        = "com3"; % Through which port will the EEG triggers be sent
comport     = serial(port);
fopen(comport);
duration    = .005;
fwrite(comport,200);
WaitSecs(duration);
fwrite(comport,0);

KbName('UnifyKeyNames');
escape      = KbName('F2');

ResponseTime=-Inf;
timeout = GetSecs() + 420;

while(ResponseTime<=0 && GetSecs() < timeout )    
    [keyPressed, thisResponseTime, keyCode] = KbCheck;
    if keyPressed && keyCode(escape)        
      cleanup;
      break;
    end
end

cleanup;

fwrite(comport,201);
WaitSecs(duration);
fwrite(comport,0);
fclose(comport);