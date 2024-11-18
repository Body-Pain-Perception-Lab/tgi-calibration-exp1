function [timepoint, tcsData] = TrialPulse(ser,baseline,speed_ramp,speed_return,targetT,trial_n,peak_duration,iti,timepoint,tcsData,filenameInfo,save_file)
% Examples    
% TrialPulse(3,32,40,40,[20 20 20 20 20],1,0,[],'tempsum.mat')
% [timepoint, tcsData] =  TrialPulse(comPort,baseline,speed_ramp,speed_return,targetT,trial_n,timepoint,tcsData,filenameInfo)
    
% Example values
%baseline = 32;
%speed_ramp = 40;
%return_ramp = 40;
%targetT = repmat(20,1,5);

%% Set parameters
TcsSetBaseLine(ser,baseline);
TcsSetDurations(ser,peak_duration);  
TcsSetRampSpeed(ser,speed_ramp);
TcsSetReturnSpeed(ser,speed_return);
TcsSetTemperatures(ser,targetT);
button_press = 0; % initialize button press variable
%% STIMULATE
TcsStimulate(ser)
for n = 1:trial_n
    currentTime = tic; % timer for recording
    recordTime = peak_duration + max(abs(targetT-baseline))/min(speed_ramp) + max(abs(targetT-baseline))/min(speed_return);
    while toc(currentTime) < recordTime
        timepoint = timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(ser);
        disp(num2str(temperatures))
        tcsData(timepoint,1) = trial_n;
        tcsData(timepoint,2) = time_sampled;
        try
            tcsData(timepoint,3:7) = temperatures;
            tcsData(timepoint,8) = button_press;
        catch
            error("the thermode is switched off")
        end
        % save data
        if save_file
            save(filenameInfo,'tcsData') % save data
        end
    end
end
end