function limitsThreshold_Launcher(scr, vars)
% Project: Multidimensional TGI Thresholding 
% Part 2: Cold/Warm Thresholding (Using Method of Limits) 
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022
%% Initial settings
% Close existing workspace
close all; clc;

%% Define task specific vars 
vars.control.exptName = 'task-limitspain_beh';
vars.ID.date_time = datestr(now,'ddmmyyyy_HHMMSS');
vars.ID.DataFileName = strcat(vars.control.exptName, '_',vars.ID.subIDstring, '_', vars.ID.date_time);    % name of data file to write to
vars.ID.UniqueFileName =  strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_',vars.control.exptName);
%% setup path
addpath(genpath('code'));
 
%% Do checks 
if vars.control.stimFlag
    ser= TcsCheckStimulator(vars);
    vars.control.ser = ser;
end
%% Start experiment
vars.control.startTask = tic;           % task start time
limitsThreshold_main(vars, scr);   % task script
endTask = toc(vars.control.startTask);  % task end time
disp(['Pain Limits Thresholds duration: ', num2str(round(endTask/60,1)), ' minutes']) % task duration

%% Restore path
rmpath(genpath('code'));
cd(vars.dir.projdir)
sca;
ShowCursor;
Priority(0);
ListenChar(0);  
end