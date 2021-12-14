InitializePsychSound(1);

cleanup


Thresh = 1200;

nrchannels  = 2;
sugLat      = [];
if IsARM
    % ARM processor, probably the RaspberryPi SoC. The Pi can not quite handle the
    % low latency settings of a desktop PC, so be more lenient:
    sugLat = 0.025;
    fprintf('Choosing a high suggestedLatencySecs setting of 25 msecs to account for lower performing ARM SoC.\n');
end
pamaster    = PsychPortAudio('Open', [], 1+8, 1, [], nrchannels,[],sugLat);
% s           = PsychPortAudio('GetStatus',pamaster);
freq        = 44100;
% freq        = s.SampleRate;
volume      = 0.5;
toneDur     = 10000;
multiplier  = 1;
standard    = 1000; 
target      = ((((Thresh))-standard)*multiplier)+standard;

PsychPortAudio('Start',pamaster,0,0,1);

% PsychPortAudio('Volume',pamaster,volume);

pasound     = PsychPortAudio('OpenSlave',pamaster,1);
padistr     = PsychPortAudio('OpenSlave',pamaster,1);

stdTone     = GenerateTone(freq,toneDur,standard); 
stdTone     = GenerateEnvelope(freq,stdTone);
tgtTone     = GenerateTone(freq,toneDur,target);
tgtTone     = GenerateEnvelope(freq,tgtTone);
%%
stdTone     = ([stdTone, stdTone])';
tgtTone     = ([tgtTone, tgtTone])';

[disTone,fs]     = audioread('Distractor.wav');
if fs ~= freq
    sprintf('Distractor sound has %d freq (not %d); fixing',fs,freq);
    [P,Q]   = rat(freq/fs);
    disTone = resample(disTone,P,Q);
end
disTone     = ([disTone, disTone]');

%% std
PsychPortAudio('Volume',pasound,0.55);
playTone(pasound,stdTone,GetSecs());
%% tgt
PsychPortAudio('Volume',pasound,0.5);
playTone(pasound,tgtTone,GetSecs());
%% dist
        tDistStart = playDistractor(padistr,disTone,GetSecs());
        PsychPortAudio('Volume',padistr,0.8);

%% stop
        tDistEnd = PsychPortAudio('Stop', padistr, 0, 1, GetSecs());
%% end
PsychPortAudio('Close')
