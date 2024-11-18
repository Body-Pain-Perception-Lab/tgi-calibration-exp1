function TaskThresholdLimits(comPort,measure,targetT,ntrials,iti,bp,save_file)
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
speed_ramp = 1; % rate of temperature rate from baseline to target
speed_return = 1;  % rate of temperature rate from target to baseline

%% Detection or Pain Thresholds
filenameInfo = fullfile(results_path, [measure '_' datestr(now,'ddmmyyyy_HHMMSS') '.mat']);
ser = TcsOpenCom(comPort); % open serial port
TcsQuietMode(ser); % quiet mode
TcsAbortStimulation(ser); % reset 
peak_duration = 0;
tic
for i = 1:ntrials
    pause(iti)
    trial_n = i; % trial counter
    [timepoint, tcsData] =  TrialThresholdLimits(ser,baseline,speed_ramp,speed_return,targetT,peak_duration,trial_n,bp,timepoint,tcsData,filenameInfo,save_file);
end
TcsCloseCom(ser) % close serial port
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
sx = [x(1) x(bi(1)+1) x(bi(2)+2)];

plot( x, t(:,1), 'o' ,'MarkerFaceColor', 'r'); hold on;
plot( x, t(:,2), 'o' ,'MarkerFaceColor', 'y');
plot( x, t(:,3), 'o' ,'MarkerFaceColor', 'g' );
plot( x, t(:,4), 'o' ,'MarkerFaceColor', 'k' );
plot( x, t(:,5), 'o' ,'MarkerFaceColor', 'b' );
plot( bx, bt, 'r*' );
xline( sx , '--' );
yline( 32, '--' );
title( ['threshold (mean): ' num2str(sprintf('%.2f',threshold_mean)) ' ' char(176) 'C'] )
grid on; zoom on;
hold off;
%pause(3)
%close all