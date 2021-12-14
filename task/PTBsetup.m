function w = PTBsetup(screenRes)
% PTBSETUP -- setup psychtoolbox screen with some sane defaults
%          screen resolution can be specified, or given empty array for full screen
     %screenRes=[];

     % osx, linux, windows, who cares :)
%      KbName('UnifyKeyNames')
     
     % Removes the blue screen flash and minimize extraneous warnings.
     % http://psychtoolbox.org/FaqWarningPrefs
     Screen('Preference', 'Verbosity', 2); % remove cli startup message 
     Screen('Preference', 'VisualDebugLevel', 3); % remove  visual logo
     %Screen('Preference', 'SuppressAllWarnings', 1);
     Screen('Preference', 'SkipSyncTests', 1);
     
     % Open a new window.
     screennum=max(Screen('Screens'));
     

     % open a PTB screen to draw thigns on
     defBgColor = [ 170 170 170]; % default background is a grey color
     [w, res] = Screen('OpenWindow', screennum,defBgColor,screenRes);
     

     %permit transparency
     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

     % set font -- depends on version of matlab/ptb
     v=version();
     v=str2double(v(1:3));
     % if newer or are using octave
     if v>=8 || exist('OCTAVE_VERSION','builtin')
         Screen('TextFont', w, 'Arial');
         Screen('TextSize', w, 26);
     else
        % older matlab+linux:
        %Screen('TextFont', w, '-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1');
        Screen('TextFont', w, '-misc-fixed-bold-r-normal--0-0-100-100-c-0-iso8859-16');
     end
    

     % Set process priority to max to minimize lag or sharing process time with other processes.
     Priority(MaxPriority(w));
    
     %do not echo keystrokes to MATLAB
     %ListenChar(2); %leaving out for now because crashing at MRRC
    
     HideCursor;

     % for sound
     InitializePsychSound();

     % specific to octave
     if exist('OCTAVE_VERSION','builtin')
       pkg load signal; % for resample, used to load sounds
       more off; % stream results to the console
     end


     % make sure output directories exist
     if ~exist('logs','dir'), mkdir('logs');  end
     if ~exist('mats','dir'), mkdir('mats'); end
end
