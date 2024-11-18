function TcsQstThresholds(targetThreshold)
tic
vars.stimFlag = 1;

%% for debugging purposes atm
vars.subNo = 1;
vars.subIDstring = sprintf('%04d', vars.subNo);
vars.OutputFolder = fullfile('..', '..', 'data', ['sub_',vars.subIDstring], filesep);
vars.DataFileName = 'qstThresholdTest';
vars.trial_n = 1;
thisTrial = 1;
Results = [];
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
    vars.speed_ramp = 1; %%% CHANGE HERE %%%
    vars.return_ramp = 1; %%% CHANGE HERE %%%
    vars.peak_duration = 0;
    vars.durations = 32; % in seconds
    vars.bp = 0;
    vars.save_file = 1;
end
%%
%TrialThresholdLevels(vars,targetT) %%% for threhsolding %%%
%TrialPulse_ver2(vars,targetT)
[Results, vars] = TrialQstThresholds(Results, vars, thisTrial, targetThreshold);
%% Save results
save(strcat(vars.OutputFolder, vars.DataFileName), 'Results', 'vars' );
%% plot
load([vars.OutputFolder vars.DataFileName])
figure; hold on
plot(Results.tcsData(:,2),Results.tcsData(:,3:7))
plot(Results.tcsData(1,2),32,'o')
%plot(tcsData(1,2)+vars.durations,32,'o')
%plot(tcsData(1,2)+vars.durations*2,32,'o')
yline(32,'--')
