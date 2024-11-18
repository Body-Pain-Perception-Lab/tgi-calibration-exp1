function [Results, vars] = TrialQstThresholds(Results, vars, thisTrial)

%% Set parameters
TcsSetBaseLine(vars.ser,vars.baseline(thisTrial));
TcsSetDurations(vars.ser,repmat(vars.durations,1,32));
TcsSetRampSpeed(vars.ser,repmat(vars.speed_ramp,1,5));
TcsSetReturnSpeed(vars.ser,repmat(vars.return_ramp,1,5));
TcsSetTemperatures(vars.ser,vars.targetThreshold(thisTrial,:));

%% Define button press
switch vars.inputDevice
    case 1
        button_press = 0; % initialize button press variable for mouse
    case 2
        button_press = [0, 0]; % initialize button press variable for QST Lab button press device
end
%% Stimulate
TcsStimulate(vars.ser)

%% Wait for button press
while sum(button_press == 0)
    vars.timepoint = vars.timepoint + 1; % update counter
    time_sampled = toc(vars.startTask);
    temperatures = TcsGetTemperatures(vars.ser);
    %disp(num2str(temperatures))
    Results.tcsData(vars.timepoint,1) = thisTrial;
    Results.tcsData(vars.timepoint,2) = time_sampled;
    Results.tcsData(vars.timepoint,3:7) = temperatures;
    
    % stop changing temperatures at upper or lower bound 
    if sum(temperatures > 49.9) >= 1 || sum(temperatures < 0.1) >= 1
        button_press = 1;
        vars.FeedbackBP = vars.FeedbackBP2;
    else
        vars.FeedbackBP = vars.FeedbackBP1;
    end
    
    % get response
    switch vars.inputDevice
        case 1 % mouse
            [~,~,buttons] = GetMouse;
            if buttons == [1 0 0] %#ok<BDSCA> % LEFT button press
                button_press = 1;
            end
        case 2
            button_press = TcsGetButtons(vars.ser);
    end
    
    % stop stimulation when button is pressed
    if button_press == 1
        TcsAbortStimulation(vars.ser) % abort stimulation
        vars.thresholdT = temperatures;
        if vars.targetThreshold(thisTrial,1) == vars.targetThreshold(thisTrial,2)
            vars.thresholdM = mean(temperatures); % average of all 5 sones of stimulator
        else
            vars.thresholdM = mean(temperatures([1 3 5])); % average of 3 zones of the stimulator (TGI stimuli)
        end
        disp(['threshold: ' num2str(vars.thresholdM)])
    end
    
    % update button press results
    Results.tcsData(vars.timepoint,8) = button_press;
end
