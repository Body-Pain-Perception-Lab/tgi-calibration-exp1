function [oldLevelScreen, oldLevelAudio] = checkPTBinstallation

    PTBv = PsychtoolboxVersion;
    if isempty(PTBv)
        disp('Please install Psychtoolbox 3. Download and installation can be found here: http://psychtoolbox.org/download');
        return
    end

    % Skip internal synch checks, suppress warnings
    oldLevelScreen = Screen('Preference', 'Verbosity', 0);
    oldLevelAudio = PsychPortAudio('Verbosity', 0);
    
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'VisualDebugLevel', 0);
end