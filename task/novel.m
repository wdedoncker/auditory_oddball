function novTone = novel(freq)
    
    novTone = struct;
    files = dir('novel_stimuli');
    files(1:2,:) = [];
    
    for i = 1:length(files)
        name    = files(i).name;
        [nov,fs]= audioread(name);   
        
        if fs ~= freq
            sprintf('Novel sound has %d freq (not %d); fixing',fs,freq);
            [P,Q]   = rat(freq/fs);
            nov = resample(nov,P,Q);
        end
        nov = nov';
        novTone(i).name = name;
        novTone(i).tone = nov;
    end

end