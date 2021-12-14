function trial_info= runTrial(toneName,type,tone,targetKey,start,finish,...
    EEG,trial_type,trial_number,comport,trigDur,blockStart_trig,trigMulti,std_trig,tgt_trig,nov_trig)

    
 % schedual the sound, wait until thisIdealStart time
 ActualStart = playTone(type,tone,start);

%EEG triggers for Tone
if trial_type(trial_number) == 1
   if EEG
       sendTrigger(comport,trigDur,((blockStart_trig+trigMulti)+std_trig));
   end
elseif trial_type(trial_number) == 5
  if EEG
       sendTrigger(comport,trigDur,((blockStart_trig+trigMulti)+tgt_trig));
  end
elseif trial_type(trial_number) == 3
  if EEG
       sendTrigger(comport,trigDur,((blockStart_trig+trigMulti)+nov_trig));
  end
end

 % record response
 [resp, keyonset] = waitForKey(targetKey,finish);
 
 % score response
 istgt=strncmp('tgt',toneName,3);
 isCorrect = (resp==1 && istgt) || (resp==0 && ~istgt); % Changed as only

 % trial information as a struct
 trial_info = struct( ...
    'response', resp, ...
    'correct', isCorrect, ...
    'keyontime',  keyonset, ...
    'sndname',  toneName, ...
    'onset', ActualStart, ...
    'rt', keyonset-ActualStart,...
    'idealonset', start);
end