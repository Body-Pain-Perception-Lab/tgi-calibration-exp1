function [keys, Results, scr, vars] = TrialPulse_TGI(keys, Results, scr, vars, thisTrial)

%% Set parameters
TcsSetBaseLine(vars.ser,vars.skinT); % skin temperature/baseline temperature
TcsSetDurations(vars.ser,repmat(vars.StimT,1,5)); % stimulation duration
TcsSetRampSpeed(vars.ser,repmat(vars.speed_ramp,1,5)); % rate of temperature change to target
TcsSetReturnSpeed(vars.ser,repmat(vars.return_ramp,1,5)); % rate of temperature change to baseline
TcsSetTemperatures(vars.ser,Results.targetT(thisTrial,:)); % 5 stimulation temperatures
button_press = [0, 0]; % initialize button press variable (unused here)
tcsData = []; 
timepoint = 0;

%% STIMULATE
TcsStimulate(vars.ser)

%% Get and save temperature data during stimulation
currentTime = tic; % timer for recording
while toc(currentTime) < vars.RecT % get tcs data for a predefined amount of time
    vars.timepoint = timepoint + 1; % update counter
    time_sampled = toc(vars.startTask);   % timing with respect to when the experiment started
    temperatures = TcsGetTemperatures(vars.ser); % get temperatures from USB port
    %disp(num2str(temperatures)) % show current temperatures
    tcsData(vars.timepoint,1) = thisTrial; % trial number
    tcsData(vars.timepoint,2) = time_sampled; % stimulation timing
    tcsData(vars.timepoint,3:7) = temperatures; % temperatures of 5 zones
    tcsData(vars.timepoint,8) = button_press(2); % whether the button was pressed (unused here)

    % KbCheck for Esc key
    if keys.KeyCode(keys.Escape)== 1
        % Save, mark the run
        vars.RunSuccessfull = 0;
        vars.Aborted = 1;
        experimentEnd(keys, Results, scr, vars);
        return
    end
    
    [~, ~, keys.KeyCode] = KbCheck;
    WaitSecs(0.001);
end
%% save tcsData
tcsFolder = fullfile(vars.OutputFolder,'stimuli');
tcsFileName = ['trial_' num2str(thisTrial)];
if ~exist(tcsFolder)
    mkdir(tcsFolder)
end
save(fullfile(tcsFolder,tcsFileName),'tcsData')

end
