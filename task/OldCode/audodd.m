function res = audodd(varargin)

%% Initialize Sound Driver
InitializePsychSound(1);

%% cleanup anything that happened before
cleanup

%% Set paths and current directory
laptop = input('Laptop (1) or PC (0) ? :');
% Laptop paths
if laptop == 1
    addpath('/Users/wdoncker/Dropbox/auditory_oddball');
    addpath('/Users/wdoncker/Dropbox/auditory_oddball/logs');
    addpath('/Users/wdoncker/Dropbox/auditory_oddball/mats');
    addpath('/Users/wdoncker/Dropbox/auditory_oddball/stimuli');
    cd('/Users/wdoncker/Dropbox/auditory_oddball');
else
% PC paths 
    addpath('C:\Users\wdedoncker\Dropbox\auditory_oddball');
    addpath('C:\Users\wdedoncker\Dropbox\auditory_oddball\logs');
    addpath('C:\Users\wdedoncker\Dropbox\auditory_oddball\mats');
    addpath('C:\Users\wdedoncker\Dropbox\auditory_oddball\stimuli');
    cd('C:\Users\wdedoncker\Dropbox\auditory_oddball');
end

%% Input
EEG     = input('EEG recording: Yes (1) or No (0) ? :');
demo    = input('Practice Trials: Yes (1) or No (0) ? :');

%% Subject Information
prompt  = {'Subject Number:','Subject Initials:','Gender (f/m)','Age', 'Date','Trait Fatigue', 'State Fatigue', 'Discrimination Threshold'}; %prompt
default = {'0','XX','fm','0','dd/mm/yy','HL','10','1500'};
dlgname = 'Setup Info';
LineNo = 1;
answer = inputdlg(prompt,dlgname,LineNo,default);
[subNum, sub, sex, age, date, Tfatigue, Sfatigue, Thresh] = deal(answer{:});

input('Press ENTER to continue');

% define subject mat and log file
nowstr = datestr(datevec(now),'yyyymmddHHMMSS');
savename=[ subNum '_' nowstr ];
logfile=fullfile('logs',[savename,'.txt']);
matfile=fullfile('mats',[savename,'.mat']);

%% Diary
diary(logfile)
fprintf('starting task for %s\n',subNum);

%% Setup Strcutures
result  = struct;

%% Keyboard Settings 
targetKey   = '5%';
EEGKey      = '=+';
KbName('UnifyKeyNames');
targetKey   = KbName(targetKey);
EEGKey      = KbName(EEGKey);
option1     = KbName('g');
option2     = KbName('4$');
option3     = KbName('f');
rightKey    = KbName('v');
selectKey   = KbName('b');
leftKey     = KbName('r');
escape      = KbName('ESCAPE');

%% EEG Settings
port        = "com4"; % Through which port will the EEG triggers be sent
if EEG
   comport = serial(port);
   fopen(comport);
else
    comport = 0;
end

trigDur         = .005;
expStart_trig   = 1;
blockStart_trig = 10;
blockEnd_trig   = 20;
expEnd_trig     = 255;

% Tone type
tgt_trig       = 5;
std_trig       = 1;

% Distractor multiplier
distMultiplier_trig     = 10;
normMultiplier_trig     = 1;

% Key press trig
press_trig      = 50;
%% Sound Parameters
nrchannels  = 2;
sugLat      = [];
if IsARM
    % ARM processor, probably the RaspberryPi SoC. The Pi can not quite handle the
    % low latency settings of a desktop PC, so be more lenient:
    sugLat = 0.025;
    fprintf('Choosing a high suggestedLatencySecs setting of 25 msecs to account for lower performing ARM SoC.\n');
end
pamaster    = PsychPortAudio('Open', [], 1+8, 1, [], nrchannels,[],sugLat);
s           = PsychPortAudio('GetStatus',pamaster);
freq        = s.SampleRate;
volume      = 0.5;
toneDur     = 150;
multiplier  = 1;
standard    = 1000; 
target      = (((str2double(Thresh))-standard)*multiplier)+standard;

PsychPortAudio('Start',pamaster,0,0,1);
PsychPortAudio('Volume',pamaster,volume);

pasound     = PsychPortAudio('OpenSlave',pamaster,1);
padistr     = PsychPortAudio('OpenSlave',pamaster,1);

stdTone     = GenerateTone(freq,toneDur,standard); 
stdTone     = GenerateEnvelope(freq,stdTone);
tgtTone     = GenerateTone(freq,toneDur,target);
tgtTone     = GenerateEnvelope(freq,tgtTone);

stdTone     = ([stdTone, stdTone])';
tgtTone     = ([tgtTone, tgtTone])';

[disTone,fs]     = audioread('Distractor.wav');
if fs ~= freq
    sprintf('Distractor sound has %d freq (not %d); fixing',fs,freq);
    [P,Q]   = rat(freq/fs);
    disTone = resample(disTone,P,Q);
end
disTone     = ([disTone, disTone]');

% pabufferstd = PsychPortAudio('CreateBuffer',[],stdTone);
% pabuffertgt = PsychPortAudio('CreateBuffer',[],tgtTone);
%% Timing Parameters
trial_dur   = 2;    % how long is each trial
snd_load_t  = 0.2;  % how much time before trial end to devote to processing. no key press is accepted in this window

%% Setup Psychtoolbox
% empty means fullscreen, otherwise [topx,topy,width,height]
% screenRes   = []; 
screenRes   = [0 0 800 600]; 
w           = PTBsetup(screenRes);

%% Instructions
txt = ['In this task, you will hear beeps.\n\n'... 
   'For each beep, decide if the beep is the TARGET or not.\n\n'...
   'If the beep IS the TARGET, press the button.\n'];
drawAndKey(w,txt);

% test standard sound
drawAndKey(w,'Ready for the STANDARD beep?');
playTone(pasound,stdTone,GetSecs());
% test target sound
drawAndKey(w,'Next is the TARGET beep');
playTone(pasound,tgtTone,GetSecs());
% both sounds
drawAndKey(w,'Now we will play STANDARD then TARGET');
playTone(pasound,stdTone,GetSecs());
WaitSecs(1.5);
playTone(pasound,tgtTone,GetSecs());
% both sounds
drawAndKey(w,'Let us play STANDARD then TARGET again');
playTone(pasound,stdTone,GetSecs());
WaitSecs(1.5);
playTone(pasound,tgtTone,GetSecs());

%% Practice Trials

if demo==1
   drawAndKey(w,['Press the button every time you hear the TARGET beep.\n\n'...
       'Ready for some pratice?']);
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey);
   exampleTrial(w,pasound,stdTone,'std',targetKey);
   exampleTrial(w,pasound,tgtTone,'tgt',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,tgtTone,'tgt',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,tgtTone,'tgt',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,tgtTone,'tgt',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey); 
   exampleTrial(w,pasound,stdTone,'std',targetKey);
end

% End of instructions
drawAndKey(w,'Ready for the Main Experiment?');

%% Output and Block Setup
result.subInfo = [{'Subject Number'},{'Name'},{'Sex'},{'Age'},{'Date'},{'TFatigue'}, {'SFatigue'}, {'Thresh'};...
    {subNum},{sub},{sex},{age},{date},{Tfatigue},{Sfatigue},{Thresh}];

blocks       = {'norm','norm','norm','norm','dist','dist','dist','dist'};
blocks       = Shuffle(blocks);

for block_number = 1:length(blocks)
    result.data(block_number).block  = block_number;
    trial_type                       = zeros(1,100);
    %% Get Sound lists
    soundlist   = randi(4);
        if soundlist == 1
            sndlist = importdata('soundlist_1.txt')';
        elseif soundlist == 2
            sndlist = importdata('soundlist_2.txt')';
        elseif soundlist == 3
            sndlist = importdata('soundlist_3.txt')';
        elseif soundlist == 4
            sndlist = importdata('soundlist_4.txt')';            
        end
    result.data(block_number).soundlist = soundlist;    
        
    for i = 1:length(sndlist)
        if isequal(sndlist{i},'std')
            trial_type(i) = 1;
        elseif isequal(sndlist{i},'tgt')
            trial_type(i) = 5;
        end
    end
    
    %% Make Sure EEG is Saving    
    waitforEEGtxt   = sprintf('EEG Recording? Start Block %d (%s)',block_number,EEGKey);
    DrawFormattedText(w,waitforEEGtxt,'center','center');
    Screen(w,'Flip');

    [~,EEGStartTime]=waitForKey(EEGKey,Inf);
    fprintf('EEGStart\t%.02f\n',EEGStartTime);

    % bring up fixation screen (last screen flip -- screen doesn't change after this)
    fixation(w,[]);    
    WaitSecs(1);
    %% Start of Experiment Trigger
    if EEG
        sendTrigger(comport,trigDur,expStart_trig);
    end
    result.EEGStart = EEGStartTime;
    %% Play Distractor
    if isequal(blocks{block_number},'dist')
        tDistStart = playDistractor(padistr,disTone,GetSecs());
        fprintf('Distractor started at system time %f seconds.\n\n', tDistStart);
        trigMulti   = distMultiplier_trig;
    else
        trigMulti   = normMultiplier_trig;
    end
    
    blockType = double(isequal(blocks{block_number},'dist'));
    result.data(block_number).blockType     = blockType;
    result.data(block_number).BlockStart    = GetSecs();
    
    %% Start of Block Trigger 
    if EEG
        sendTrigger(comport,trigDur,(blockStart_trig*trigMulti))
    end
    %% Loop  through trials
    for trial_number = 1:length(sndlist)
       thisIdealStart   = result.data(block_number).BlockStart +  (trial_number - 1) * trial_dur;
       thisMaxEnd       = thisIdealStart + trial_dur - snd_load_t;
       toneName         = sndlist{trial_number};

       if trial_type(trial_number) == 1
           tone     = stdTone;
       elseif trial_type(trial_number) == 5
           tone     = tgtTone;
       end

       %% Run Task
       trial_info   = runTrial(toneName,pasound,tone,targetKey,...
           thisIdealStart,thisMaxEnd,...
           EEG,trial_type,trial_number,comport,trigDur,blockStart_trig,trigMulti,std_trig,tgt_trig);
       
       %% EEG Trigger for Button Press
       if EEG
           if trial_info.response == 1
                sendTrigger(comport,trigDur,((blockStart_trig*trigMulti)+press_trig)); 
           end
       end
       
       % print what happened for diary logging in case of mat corruption
       fprintf('trial %02d\tpushed %d\tscore %d\tRT %.02f\tsndon %.02f\tsnd %s\n',...
         trial_number, trial_info.response, ...
         trial_info.correct, trial_info.rt,...
         trial_info.onset-EEGStartTime,trial_info.sndname);
       
        result.data(block_number).timing(trial_number) = trial_info;
       
    end
    %% End of Block Trigger %%
    if EEG
        sendTrigger(comport,trigDur,(blockEnd_trig*trigMulti));
    end
    %% Stop Distractor Sound
    if isequal(blocks{block_number},'dist')
        tDistEnd = PsychPortAudio('Stop', padistr, 0, 1, GetSecs());
        fprintf('Distractor ended at system time %f seconds.\n\n', tDistEnd);
    end
    
    %% End of Block
    finishBlock = GetSecs();
    fprintf('Finished Block %02d\t%.02f\n',block_number,finishBlock);
    result.data(block_number).endBlock = finishBlock;
    WaitSecs(1);    
    
    %% Save at the end of each Block
    save(matfile,'result');
        
   %% Questions at the End of the Block
   [key,ResponseTime] = loudness(w,option1,option2,option3,escape);
   result.data(block_number).loudness       = key;
   result.data(block_number).loudnessTime   = ResponseTime;
   
   [effort,ResponseTime] = effortVAS(w,rightKey,selectKey,leftKey,escape);
   result.data(block_number).effort       = effort;
   result.data(block_number).effortTime   = ResponseTime;   
   
end
%% End of Experiment Trigger 
if EEG
    sendTrigger(comport,trigDur,expEnd_trig);
end
%% End of Experiment
finishTime=GetSecs();
fprintf('Finished Main Loop\t%.02f\n',finishTime);
WaitSecs(1);
result.finishtime= finishTime;
save(matfile,'result','subNum')
if EEG
    fclose(comport);
end
DrawFormattedText(w,'Well Done!\n\nEnd of Experiment','center','center');
Screen(w,'Flip');
WaitSecs(3);
cleanup
end