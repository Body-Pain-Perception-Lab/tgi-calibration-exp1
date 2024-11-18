function [vars] = TrialThresholdLimits_vars(vars,targetT)
% Examples    
% TrialThresholdLimits(3,32,1,1,[0 0 0 0 0],1,0,[],'cdt.mat')
% [timepoint, tcsData] =  TrialThresholdLimits(comPort,baseline,speed_ramp,speed_return,targetT,trial_n,timepoint,tcsData,filenameInfo)
    
% Example values
%baseline = 32;
%speed_ramp = 1;
%return_ramp = 1;
%targetT = [0 0 0 0 0];

%durations = repmat(max(abs(targetT-baseline))/min(speed_ramp),1,5) + peak_duration;
%% Set parameters
TcsSetBaseLine(vars.ser,vars.skinT);
%TcsSetDurations(vars.ser,repmat(vars.durations,1,5));
TcsSetRampSpeed(vars.ser,repmat(vars.speed_ramp,1,5));
TcsSetReturnSpeed(vars.ser,repmat(vars.return_ramp,1,5));
TcsSetTemperatures(vars.ser,targetT);
button_press = [0 0]; % initialize button press variable
%% Stimulate
TcsStimulate(vars.ser)
%% Wait for button press
if vars.bp % if button press
    while button_press(2) == 0
        vars.timepoint = vars.timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(vars.ser);
        %disp(num2str(temperatures))
        button_press = TcsGetButtons(vars.ser);
        tcsData(vars.timepoint,1) = vars.trial_n;
        tcsData(vars.timepoint,2) = time_sampled;
        tcsData(vars.timepoint,3:7) = temperatures;
        tcsData(vars.timepoint,8) = button_press(2);
        % save data
        if vars.save_file
            save(vars.TcsFileName,'tcsData') % save data
        end
        % stop changing temperatures at upper or lower bound 
        if sum(temperatures > 49.9) >= 1 || sum(temperatures < 0.1) >= 1
            button_press(2) = 1;
        end
        % stop stimulation when button is pressed
        if button_press(2) == 1
            TcsAbortStimulation(vars.ser) % abort stimulation
            threshold_value = mean(temperatures);
            disp(['threshold: ' num2str(threshold_value)])
        end
        %pause(0.1) % get data every 10 ms
    end
else
%% Wait until the end of the stimulation
    currentTime = tic; % timer for recording
    recordTime = vars.durations*2 + vars.peak_duration;
    while toc(currentTime) < recordTime
        vars.timepoint = vars.timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(vars.ser);
        disp(num2str(temperatures))
        button_press = TcsGetButtons(vars.ser);
        tcsData(vars.timepoint,1) = vars.trial_n;
        tcsData(vars.timepoint,2) = time_sampled;
        tcsData(vars.timepoint,3:7) = temperatures;
        tcsData(vars.timepoint,8) = button_press(2);
        % save data
        if vars.save_file
            save(vars.TcsFileName,'tcsData') % save data
        end
        
    end
end

end