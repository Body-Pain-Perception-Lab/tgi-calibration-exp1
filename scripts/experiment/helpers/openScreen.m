function [scr]=openScreen(scr, vars)
% open screen window
%if ~exist('scr','var')
    if ~isfield(scr, 'win')
        % Diplay configuration
        %[scr] = displayConfig(scr);

        if vars.control.devFlag
            [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray, [0 0 1000 1000]); %,[0 0 1920 1080] mr screen dim
        else
            [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray); %,[0 0 1920 1080] mr screen dim
        end
        
        %PsychColorCorrection('SetEncodingGamma', scr.win);
        
        % Set text size, dependent on screen resolution
        if any(logical(scr.winRect(:)>3000))       % 4K resolution
            scr.TextSize = 65;
        else
            scr.TextSize = 30;
        end
        Screen('TextSize', scr.win, scr.TextSize);
        
        % Set priority for script execution to realtime priority:
        scr.priorityLevel = MaxPriority(scr.win);
        Priority(scr.priorityLevel);
        
        % Determine stim size in pixels
        scr.dist = scr.ViewDist;
        scr.width  = scr.MonitorWidth;
        scr.resolution = scr.winRect(3:4);                    % number of pixels of display in horizontal direction
    end
%end
end
