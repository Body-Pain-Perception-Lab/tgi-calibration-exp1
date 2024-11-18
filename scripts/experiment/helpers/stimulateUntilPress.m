function [thresholdRaw, thresholdMean, stimTime,stimOn, stimOff, tcsData] = stimulateUntilPress(scr,vars,keys,type,Tcold,Twarm)

%Type: 0: cold, 1: warm, 2:TGI
%% Set parameters
TcsSetBaseLine(vars.control.ser,vars.task.Tbaseline);
TcsSetDurations(vars.control.ser,repmat(vars.stim.durationS,1,5));
TcsSetRampSpeed(vars.control.ser,repmat(vars.stim.speed_ramp,1,5)); % rate of temperature change to target
TcsSetReturnSpeed(vars.control.ser,repmat(vars.stim.return_ramp,1,5)); % rate of temperature change to baseline
% TcsSetTemperatures(vars.ser,vars.targetThreshold(thisTrial,:));

% randomize stimulation bars

switch type
    case 0 % Cold. Select one within the 4 possibilities.
        possibilities = {[1 1 0 0 0],...
            [0 1 1 0 0],...
            [0 0 1 1 0],...
            [0 0 0 1 1]};
%         possibilities_idx = randi(4);
        possibilities_idx = mod(vars.ID.subNo,4)+1;
        tcs_temperatures = single(possibilities{possibilities_idx});
        tcs_temperatures(tcs_temperatures==0)= vars.task.Tbaseline;
        tcs_temperatures(tcs_temperatures==1)= Tcold;
        
    case 1 % Warm. Selct one within the 3 possibilities
        possibilities = {[1 1 1 0 0],...
            [0 1 1 1 0],...
            [0 0 1 1 1]};
%         possibilities_idx = randi(3);
        possibilities_idx = mod(vars.ID.subNo,3)+1;
        tcs_temperatures = possibilities{possibilities_idx}*Twarm;
        tcs_temperatures(tcs_temperatures==0)= vars.task.Tbaseline;
        
    case 2 % TGI. Selct one within the 3 possibilities
        possibilities = [1 0 1 0 1];
        tcs_temperatures = possibilities*Twarm;
        tcs_temperatures(tcs_temperatures==0) = Tcold;
        
%     case 3 %Baseline
%         tcs_temperatures = single(ones(1,5)*vars.task.Tbaseline);
end


TcsSetTemperatures(vars.control.ser,tcs_temperatures); % 5 stimulation temperatures

timepoint=0;
button_press = 0; 
%% STIMULATE
stimOn = GetSecs;

TcsStimulate(vars.control.ser)
%% Get and save temperature data during stimulation
stimTime = tic; % timer for recording

%% Wait for button press
while sum(button_press == 0)
    timepoint = timepoint + 1; % update counter
    time_sampled = toc(vars.control.startTask);   % timing with respect to when the experiment started
    temperatures = TcsGetTemperatures(vars.control.ser); % get temperatures from USB port
    %     disp(num2str(temperatures)) % show current temperatures
    tcsData(timepoint,1) = vars.control.thisTrial; % trial number
    tcsData(timepoint,2) = time_sampled; % stimulation timing
    tcsData(timepoint,3:7) = temperatures; % temperatures of 5 zones

    % stop changing temperatures at upper or lower bound 
    if sum(temperatures > (vars.task.Tmax-0.1)) >= 1 || sum(temperatures < (vars.task.Tmin+0.1)) >= 1
        button_press = 1;
        feedback = 0; %Outside Limits feedback
    else
        feedback=1;
    end
    
        % get response
    [~,~,buttons] = GetMouse;
    [~, ~, keys.KeyCode] = KbCheck;
    WaitSecs(0.001);

    if (isequal(buttons,[1 0 0])) || (keys.KeyCode(keys.Space)==1)% LEFT button press or space
        button_press = 1;
    elseif  keys.KeyCode(keys.Escape)==1
        TcsAbortStimulation(vars.control.ser) % abort stimulation
        % Save, mark the run
        vars.control.RunSuccessfull = 0;
        vars.control.Aborted = 1;
        experimentEnd(vars, scr, keys, Results)
        return
    end
    
    % stop stimulation when button is pressed
    if button_press == 1
        TcsAbortStimulation(vars.control.ser) % abort stimulation
        stimOff = GetSecs;
        thresholdRaw = temperatures;
        
        if type==0 || type==1
            thresholdMean = mean(temperatures(find(possibilities{possibilities_idx}))); % average of active zones of the stimulator
        else
            thresholdMean = [mean(temperatures([1 3 5])) mean(temperatures([2 4]))]; % average of 3 zones of the stimulator (TGI stimuli)
        end
        disp(['threshold: ' num2str(thresholdMean)])
    end
    
    % update button press results
    tcsData(timepoint,8) = button_press;
end

%% Provide feedback about button press
Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
DrawFormattedText(scr.win, uint8(vars.instructions.FeedbackBP{feedback+1}), 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
WaitSecs(vars.task.feedbackBPtime);

% Draw Fixation again
Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
scr = drawFixation(scr); % fixation point
[~, ~] = Screen('Flip', scr.win);
end