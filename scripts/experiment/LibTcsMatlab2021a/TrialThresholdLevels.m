function vars = TrialThresholdLevels(vars,targetThreshold)

%% Set parameters
TcsSetBaseLine(vars.ser,vars.skinT);
TcsSetDurations(vars.ser,repmat(vars.durations,1,32));
TcsSetRampSpeed(vars.ser,repmat(vars.speed_ramp,1,5));
TcsSetReturnSpeed(vars.ser,repmat(vars.return_ramp,1,5));
if mean(targetThreshold) < 32
    TcsSetTemperatures(vars.ser,ones(1,5)*0);
elseif mean(targetThreshold) > 32
    TcsSetTemperatures(vars.ser,ones(1,5)*50);
end
button_press = 0; % initialize button press variable
%% Stimulate
TcsStimulate(vars.ser)
%% Wait for button press
while button_press == 0
    vars.timepoint = vars.timepoint + 1; % update counter
    time_sampled = toc;
    temperatures = TcsGetTemperatures(vars.ser);
    %disp(num2str(temperatures))
    %button_press = TcsGetButtons(vars.ser);
    vars.tcsData(vars.timepoint,1) = vars.trial_n;
    vars.tcsData(vars.timepoint,2) = time_sampled;
    vars.tcsData(vars.timepoint,3:7) = temperatures;
    %vars.tcsData(vars.timepoint,8) = button_press(2);
    % save data
    %if vars.save_file
    %    save(vars.filenameInfo,vars.tcsData) % save data
    %end
    % stop changing temperatures at upper or lower bound 
    if sum(temperatures > 49.9) >= 1 || sum(temperatures < 0.1) >= 1
        button_press = 1;
    end
    % stop stimulation when button is pressed
    if button_press == 1
        TcsAbortStimulation(ser) % abort stimulation
        vars.threshold = mean(temperatures);
        disp(['threshold: ' num2str(vars.threshold)])
    end
    % get response
    [~,~,buttons] = GetMouse;
    if buttons == [1 0 0] %#ok<BDSCA> % LEFT button press
        button_press = 1;
    end
end
