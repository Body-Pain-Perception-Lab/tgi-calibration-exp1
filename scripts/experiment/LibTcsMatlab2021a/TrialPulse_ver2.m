function [vars] = TrialPulse_ver2(vars,targetT)
%(ser,baseline,speed_ramp,speed_return,targetT,trial_n,peak_duration,iti,timepoint,tcsData,filenameInfo,save_file)
% Examples    
% TrialPulse(3,32,40,40,[20 20 20 20 20],1,0,[],'tempsum.mat')
% [timepoint, tcsData] =  TrialPulse(comPort,baseline,speed_ramp,speed_return,targetT,trial_n,timepoint,tcsData,filenameInfo)
    
% Example values
%baseline = 32;
%speed_ramp = 40;
%return_ramp = 40;
%targetT = repmat(20,1,5);

%% Set parameters
TcsSetBaseLine(vars.ser,vars.skinT);
TcsSetDurations(vars.ser,repmat(vars.durations,1,5));
TcsSetRampSpeed(vars.ser,repmat(vars.speed_ramp,1,5));
TcsSetReturnSpeed(vars.ser,repmat(vars.return_ramp,1,5));
TcsSetTemperatures(vars.ser,targetT);
button_press = [0, 0]; % initialize button press variable

%% STIMULATE
TcsStimulate(vars.ser)
for n = 1%:vars.trial_n
    currentTime = tic; % timer for recording
    %recordTime = peak_duration + max(abs(targetT-baseline))/min(speed_ramp) + max(abs(targetT-baseline))/min(speed_return);
    recordTime = vars.durations*2;
    while toc(currentTime) < recordTime
        vars.timepoint = vars.timepoint + 1; % update counter
        time_sampled = toc;
        temperatures = TcsGetTemperatures(vars.ser);
        %disp(num2str(temperatures))
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