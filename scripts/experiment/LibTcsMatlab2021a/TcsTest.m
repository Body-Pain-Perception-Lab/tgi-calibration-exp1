function TcsTest(targetT)

vars.stimFlag = 1;
vars.TcsFileName = 'test_levels.mat';
vars.trial_n = 1;
%% Parameters
% define and check USB port
if ~vars.stimFlag 
    disp('Debugging without stimulator')
else
    try
        vars.ser = TcsOpenCom(4); 
    catch
        warning('The USB port is not defined correctly. Please change vars.ser')
        return
    end
    % test port and check battery 
    [~, pct] = TcsGetBattery(vars.ser);
    if isempty(pct)
        warning('Check whether stimulator is turned on and then restart experimenterLuncher')
        return
    else
        vars.battery = pct;
        disp(['Battery: ' num2str(pct) ' %']);
    end
    TcsQuietMode(vars.ser) % set quiet mode
    % Define stimulation parameters
    vars.skinT = 32;
    vars.timepoint = 0;
    vars.tcsData = [];
    vars.speed_ramp = 20; %%% CHANGE HERE %%%
    vars.return_ramp = 20; %%% CHANGE HERE %%%
    vars.peak_duration = 0;
    vars.durations = 7; % in seconds
    vars.bp = 0;
    vars.save_file = 1;
    vars.filenameInfo = vars.TcsFileName;
end
%%
%TrialThresholdLevels(vars,targetT) %%% for threhsolding %%%
TrialPulse_ver2(vars,targetT)
%% QST thresholds
%vars.bp = 1;
%vars.speed_ramp = 1; %%% CHANGE HERE %%%
%vars.return_ramp = 1; %%% CHANGE HERE %%%
%TrialThresholdLimits_vars(vars,targetT)

%% plot
load(vars.TcsFileName)
figure; hold on
plot(tcsData(:,2),tcsData(:,3:7))
plot(tcsData(1,2),32,'o')
%plot(tcsData(1,2)+vars.durations,32,'o')
%plot(tcsData(1,2)+vars.durations*2,32,'o')
yline(32,'--')
