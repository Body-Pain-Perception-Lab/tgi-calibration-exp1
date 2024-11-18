function TaskTempsumPHS(comPort,measure,speed_ramp,stimulus_targetT,threshold_targetT,ntrials,peak_duration,iti,save_file)
%% Example
% TaskThresholdLimits('cdt',zeros(1,5),3,5)
% TaskThresholdLimits('wdt',ones(1,5)*50,3,5)
% TaskThresholdLimits('cpt',zeros(1,5),3,10)
% TaskThresholdLimits('hpt',ones(1,5)*50,3,10)

%% Parameters
% define path where to save results
results_path = 'C:\Users\stimuser\Documents\VMP2_pain';

% parameters
timepoint = 0; % intitialize timepoint variable
tcsData = []; % intitialize empty data frame for data storing
baseline = 32; % baseline
%% Stimuli
filenameInfo = fullfile(results_path, [measure '_' datestr(now,'ddmmyyyy_HHMMSS') '.mat']);
ser = TcsOpenCom(comPort); % open serial port
TcsQuietMode(ser); % quiet mode
TcsAbortStimulation(ser); % reset 

tic
for i = 1:length(ntrials)
    trial_n = i;
    % square stimulus
    speed_return = speed_ramp; % rate of temperature change
    [timepoint, tcsData] = TrialPulse(ser,baseline,speed_ramp,speed_return,stimulus_targetT,i,peak_duration,iti,timepoint,tcsData,filenameInfo,save_file);
    % enable follow mode
    %TcsFollowMode(ser);
    % temperature change threshold
    bp = true;
    speed_ramp = 1; speed_return = speed_ramp; % rate of temperature change
    [timepoint, tcsData, ~] = TrialThresholdLimits(ser,baseline,speed_ramp,speed_return,threshold_targetT,peak_duration,trial_n,bp,timepoint,tcsData,filenameInfo,save_file);
  
end
TcsCloseCom(ser); % close serial port
%% Mean threshold and plot
threshold_data = tcsData(tcsData(:,8) == 1,3:7);
threshold_mean = mean(mean(threshold_data));
disp(['threshold (mean): ' num2str(threshold_mean)])

%display 5x temp curves
x = tcsData(:,2);
t = tcsData(:,3:7);

bi = find(tcsData(:,8) == 1);
bx = tcsData(bi,2);
bt = mean(tcsData(bi,3:7),2);
%sx = [x(1) x(bi(1)+1) x(bi(2)+2)];

plot( x, t(:,1) ); hold on;
plot( x, t(:,2) );
plot( x, t(:,3) );
plot( x, t(:,4) );
plot( x, t(:,5) );
plot( bx, bt, 'r*' );
%xline( sx , '--');
title( ['threshold (mean): ' num2str(sprintf('%.2f',threshold_mean)) ' ' char(176) 'C'] )
grid on; zoom on;
hold off;
%pause(3)
%close all