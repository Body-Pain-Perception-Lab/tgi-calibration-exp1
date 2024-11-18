function TaskPulse(comPort,measure,targetT,ntrials,peak_duration,iti,save_file)
%% Example
% TaskPulse('cdt',zeros(1,5),3,2,true)
% TaskPulse('wdt',ones(1,5)*50,3,2,true)

%% Parameters
% define path where to save results
results_path = 'C:\Users\stimuser\Documents\VMP2_pain';

% parameters
timepoint = 0; % intitialize timepoint variable
tcsData = []; % intitialize empty data frame for data storing

baseline = 20; % baseline
speed_ramp = 40; % rate of temperature rate from baseline to target
speed_return = 40;  % rate of temperature rate from target to baseline

%% Detection or Pain Thresholds
filenameInfo = fullfile(results_path, [measure '_' datestr(now,'ddmmyyyy_HHMMSS') '.mat']);
ser = TcsOpenCom(comPort); % open serial port
TcsQuietMode(ser); % quiet mode
TcsAbortStimulation(ser); % reset 

tic
[~, tcsData] = TrialPulse(ser,baseline,speed_ramp,speed_return,targetT,ntrials,peak_duration,iti,timepoint,tcsData,filenameInfo,save_file);
TcsCloseCom(ser); % close serial port
%% Plot

%display 5x temp curves
x = tcsData(:,2);
t = tcsData(:,3:7);
plot( x, t(:,1) ); hold on;
plot( x, t(:,2) );
plot( x, t(:,3) );
plot( x, t(:,4) );
plot( x, t(:,5) );

title( ['Pulse temperature: ' num2str(sprintf('%.2f',mean(targetT))) ' ' char(176) 'C'] )
grid on; zoom on;
hold off;
%pause(3)
%close all