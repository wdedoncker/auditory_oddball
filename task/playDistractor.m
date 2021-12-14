function onset = playDistractor(type,tone,start)

PsychPortAudio('FillBuffer',type,tone);
onset = PsychPortAudio('Start',type,1,start,1);

end