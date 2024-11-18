function [timepoint, tcsData, tsl_value] = TaskLimen(comPort,measure,targetT,ntrials,iti,bp,save_file)
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
tsl_value = 32;
pause(iti)
tic
for i = 1:ntrials
    if mod(i,2) == 1 % odd trial / warming
        trial_n = i; % trial counter
        baseline = tsl_value; 
        [timepoint, tcsData, tsl_value] = TrialLimen(ser,baseline,speed_ramp,speed_return,targetT(1,:),peak_duration,trial_n,bp,timepoint,tcsData,filenameInfo,save_file);
    elseif mod(i,2) == 0 % even trial / cooling 
        trial_n = i; % trial counter
        baseline = tsl_value; 
        [timepoint, tcsData, tsl_value] = TrialLimen(ser,baseline,speed_ramp,speed_return,targetT(2,:),peak_duration,trial_n,bp,timepoint,tcsData,filenameInfo,save_file);
    end
end
TcsSetBaseLine(ser,32)
TcsStimulate(ser)
TcsAbortStimulation(ser)
TcsCloseCom(ser) % close serial port
%% Mean tsl and plot
%display 5x temp curves
n = 1:ntrials;
x = tcsData(:,2);
t = tcsData(:,3:7);
bi = find(tcsData(:,8) == 1);
bi1 = bi +1;
bx = tcsData(bi,2);
bt = mean(tcsData(bi,3:7),2);
btw = bt(n(mod(n,2)==1)); % index of odd numbers
btc = bt(n(mod(n,2)==0)); % index of even numbers

tsl_mean = mean(btw-btc);
sx = [x(1); x(bi1(1:end-1))];
disp(['TSL (mean): ' num2str(tsl_mean)])

plot( x, t(:,1), 'o' ,'MarkerFaceColor', 'r'); hold on;
plot( x, t(:,2), 'o' ,'MarkerFaceColor', 'y');
plot( x, t(:,3), 'o' ,'MarkerFaceColor', 'g' );
plot( x, t(:,4), 'o' ,'MarkerFaceColor', 'k' );
plot( x, t(:,5), 'o' ,'MarkerFaceColor', 'b' );
plot( bx, bt, 'r*' );
xline( sx , '--' );
yline( 32, '--' );
title( ['tsl (mean): ' num2str(sprintf('%.2f',tsl_mean)) ' ' char(176) 'C'] )
grid on; zoom on;
hold off;
%pause(3)
%close all