function [timepoint, tcsData, tsl_value] = TrialLimen(ser,baseline,speed_ramp,return_ramp,targetT,peak_duration,trial_n,bp,timepoint,tcsData,filenameInfo,save_file)
% Examples    
% TrialThresholdLimits(3,32,1,1,[0 0 0 0 0],1,0,[],'cdt.mat')
% [timepoint, tcsData] =  TrialThresholdLimits(comPort,baseline,speed_ramp,speed_return,targetT,trial_n,timepoint,tcsData,filenameInfo)
    
% Example values
%baseline = 32;
%speed_ramp = 1;
%return_ramp = 1;
%targetT = [0 0 0 0 0];

durations = (max(abs(baseline-32)) + max(abs(targetT-32)))/min(speed_ramp) + peak_duration;
durations = repmat(durations/2,1,5);
%% Set parameters
TcsSetBaseLine(ser,baseline);
TcsSetDurations(ser,durations);
TcsSetRampSpeed(ser,repmat(speed_ramp,1,5));
TcsSetReturnSpeed(ser,repmat(return_ramp,5));
TcsSetTemperatures(ser,targetT);
button_press = 0; % initialize button press variable
%% Stimulate
TcsStimulate(ser)
%% Wait for button press
currentTime = tic; % timer to record button presses (i.e., start recording button presses with a delay of 250 ms from start, otherwise one single button press is logged multiple times)
if bp % if button press
    while button_press == 0
        timepoint = timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(ser);
        disp(num2str(temperatures))
        button_press = TcsGetButtons(ser);
        tcsData(timepoint,1) = trial_n;
        tcsData(timepoint,2) = time_sampled;
        try
            tcsData(timepoint,3:7) = temperatures;
        catch
            error("the thermode is switched off")    
        end
        if toc(currentTime) < 0.25 % fixed delay, as response times are not expected to be lower than 250 ms
            button_press = [0, 0];
        else
            tcsData(timepoint,8) = button_press(2);
        end
        % save data
        if save_file
            save(filenameInfo,'tcsData') % save data
        end
        % stop changing temperatures at upper or lower bound 
        if sum(temperatures > 49.9) >= 1 || sum(temperatures < 0.1) >= 1
            button_press(2) = 1;
        end
        % stop stimulation when button is pressed
        if button_press(2) == 1
            TcsAbortStimulation(ser) % abort stimulation
            TcsFollowMode(ser) % enable follow mode
            tsl_value = mean(temperatures);
            disp(['tsl_value: ' num2str(tsl_value)])
        end
        %pause(0.1) % get data every 10 ms
    end
else
%% Wait until the end of the stimulation
    currentTime = tic; % timer for recording
    if targetT == repmat(32,1,5)
        recordTime = durations/2 + iti;
    else
        recordTime = durations + iti;
    end
    while toc(currentTime) < recordTime
        timepoint = timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(ser);
        disp(num2str(temperatures))
        button_press = TcsGetButtons(ser);
        tcsData(timepoint,1) = trial_n;
        tcsData(timepoint,2) = time_sampled;
        try
            tcsData(timepoint,3:7) = temperatures;
            tcsData(timepoint,8) = button_press(2);
        catch
            error("the thermode is switched off")    
        end
        % save data
        if save_file
            save(filenameInfo,'tcsData') % save data
        end
     if targetT == repmat(32,1,5)
         if any(temperatures == 32)
             TcsAbortStimulation(ser)
             TcsFollowMode(ser) % enable follow mode, otherwise the tmeperature will start returning to baseline = 32 right away
         end
     end
    end
end

end