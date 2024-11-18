function PsiThreshold_Launcher(scr, vars)
% Project: Multidimensional TGI Thresholding 
% Parts 2 and 3: Cold/Warm Thresholding or TGI Thresholding (Using Psi - PALAMEDES) 
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022

%% Initial settings
% Close existing workspace
close all; clc;

%% setup path
addpath(genpath('code'));
 
%% Do checks 
if vars.control.stimFlag
    ser= TcsCheckStimulator(vars);
    vars.control.ser = ser;
end
%% Start experiment
vars.control.startTask = tic;           % task start time
psiThreshold_main(vars, scr);   % task script
endTask = toc(vars.control.startTask);  % task end time
disp(['Psi Thresholds duration: ', num2str(round(endTask/60,1)), ' minutes']) % task duration

%% Restore path
rmpath(genpath('code'));

cd(vars.dir.projdir)
sca;
ShowCursor;
Priority(0);
ListenChar(0);  
