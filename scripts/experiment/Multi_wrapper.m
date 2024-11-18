 function Multi_wrapper(whichPart)
%
% Project: Multidimensional TGI Thresholding 
%
% Input: whichPart  optional argument to only run one of the TPL component tasks
%       0   Tutorial
%       1   TGI Multidimensional Thresholding (FAST)
%       2   Cold/Warm Thresholding (Using either Method of Limits or Psi)
%       3   TGI Thresholding (1D - Psi - PALAMEDES) 
%       4   Threshold Rating Evaluation (VAS ratings)
%
% Sets paths, and calls functions
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022

%% Close existing workspaces
close all; clc;
%% Define general vars across tasks
vars.dir.projdir = pwd;
vars.control.devFlag  = 0;              % Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor
vars.control.stimFlag = 1;              % Development flag 2. Set to 0 when developing the task without a stimulator
vars.ID.subNo = input('What is the subject number (e.g. 0001)?   ');
vars.ID.sesNo = input('What is the session number (e.g. 0001)?   ');
vars.control.language = input('Which language: English (1) or Danish (2)?   ');
vars.control.startTrialN = 1;

% Define subject No if the value is missing 
if isempty(vars.ID.subNo)
    vars.ID.subNo = 9999; % debugging                                            
end

% Define session No if the value is missing 
if isempty(vars.ID.sesNo)
    vars.ID.sesNo = 1; % debugging                                            
end

vars.ID.subIDstring = sprintf('%04d', vars.ID.subNo);
vars.ID.sesIDstring = sprintf('%01d', vars.ID.sesNo);

%% Prepare metadata
participant.MetaDataFileName = strcat(vars.ID.subIDstring, '_metaData'); 
participant.partsCompleted = zeros(1,4);

% Check if the subject folder already exists in data dir
vars.dir.OutputFolder = fullfile(vars.dir.projdir, 'data', ['sub-',vars.ID.subIDstring], filesep);
if ~exist(vars.dir.OutputFolder, 'dir') 
    mkdir(vars.dir.OutputFolder)
else
    %try load(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant'); end
end

%% Set up paths
addpath(vars.dir.OutputFolder);
addpath(genpath('stimuli'));
addpath(genpath('..\LibTcsMatlab2021a'));
addpath(genpath('helpers'))
%% PTB and screen settings
[oldLevelScreen, oldLevelAudio] = checkPTBinstallation;

% 
scr.ViewDist = 56; 
[scr] = displayConfig(scr);
AssertOpenGL;

%% 00 Run Tutorial OR Adaptation Trials
if ((nargin < 1) || (whichPart==0))
    vars.control.taskN = 0;
    runTutorial = input('Would you like to run a tutorial? 1-yes 0-no (run Adaptation Trials instead) ');
    if runTutorial
        cd(fullfile('.', 'tasks', '00_tutorial'))
        addpath(genpath('helpers'))
        tutorial_MT (scr,vars);
    else
        disp('Running Adaptation Trials ')
        cd(fullfile('.', 'tasks', '02a_PsiThr'))
        PsiThreshold_Launcher(scr,vars); % Launcher
    end
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Tutorial completed. Continue to the main tasks? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end
%% 01 Cold and Warm Detection Thresholds

if ((nargin < 1) || (whichPart==1)) %&& (participant.partsCompleted(1) == 0)
    vars.control.taskN = 1;
%     vars.control.whichMethodCW = input('Which method would you like to use to estimate Detection thresholds? (1)Psi (otherwise)Method of Limits    ');
    vars.control.whichMethodCW = 1;
    
    switch vars.control.whichMethodCW
        case 1
            vars.control.whichBlock = input('Which Sensation would you like to threshold now? (0)Cold (1)Warm    ');
            cd(fullfile('.', 'tasks', '02a_PsiThr'))
            PsiThreshold_Launcher(scr,vars); % Launcher
         otherwise
            cd(fullfile('.', 'tasks', '02b_MethodLimits')) 
            limitsThreshold_Launcher(scr,vars); % Launcher
    end
    % if vars.RunSuccessfull
    participant.partsCompleted(1) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Cold and Warm Detection Thresholds completed. Continue to Cold and Warm Pain Thresholds? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 02 Cold and Warm Pain Thresholds

if ((nargin < 1) || (whichPart==2)) %&& (participant.partsCompleted(2) == 0)
    vars.control.taskN = 2;
%     vars.control.whichMethodCW = input('Which method would you like to use to estimate Burning thresholds? (1)Psi (otherwise)Method of Limits    ');
    vars.control.whichMethodCW = 1;

    switch vars.control.whichMethodCW
        case 1
            vars.control.whichBlock = input('Which Sensation would you like to threshold now? (0)Cold (1)Warm    ');
            cd(fullfile('.', 'tasks', '02a_PsiThr'))
            PsiThreshold_Launcher(scr,vars); % Launcher
         otherwise
            cd(fullfile('.', 'tasks', '02b_MethodLimits'))
            limitsThreshold_Launcher(scr,vars); % Launcher
    end
    % if vars.RunSuccessfull
    participant.partsCompleted(2) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');

    % Continue to next task
    if (nargin < 1)
        goOn1 = input('Cold and Warm Pain Thresholds completed. Continue to Multi TGI Thresholding (FAST)? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 03 Run TGI Multidimensional Thresholding (FAST)
if ((nargin < 1) || (whichPart==3)) %&& (participant.partsCompleted(taskN) == 0)
    vars.control.taskN = 3;
    cd(fullfile('.', 'tasks', '01_tgiMulti'))
    addpath(genpath('code'))
    tgiMulti_Launcher(scr, vars); % Launcher
    participant.partsCompleted(3) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('TGI Multidimensional threshold task completed. Continue to VAS assesment? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end

%% 04 TGI Rating
if ((nargin < 1) || (whichPart==4)) %&& (participant.partsCompleted(taskN) == 0)
    vars.control.taskN = 4;
    % Run the task
    cd(fullfile('.', 'tasks', '04_Rating'))    
    tgiRating_Launcher(scr, vars); % Launcher
    % if vars.RunSuccessfull
    participant.partsCompleted(4) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
    
    % Continue to next task
    if (nargin < 1)
        goOn1 = input('VAS assessment completed. Continue to Psi-TGI Thresholding? 1-yes, 0-no ');
        if ~goOn1
            return
        end
    end
end
%% 05 PSI Threshold

if ((nargin < 1) || (whichPart==5)) %&& (participant.partsCompleted(3) == 0)
    vars.control.taskN = 5;
    cd(fullfile('.', 'tasks', '02a_PsiThr'))
    PsiThreshold_Launcher(scr,vars); % Launcher
    % if vars.RunSuccessfull
    participant.partsCompleted(5) = 1;
    % Save metadata
    save(fullfile(vars.dir.OutputFolder, ['sub_', participant.MetaDataFileName]), 'participant');
end



%% Finish up
% Copy data files to 1_VMP_aux
% copy2VMPaux(participant.subNo);

% Close screen etc
rmpath(genpath('code'));
rmpath(vars.dir.OutputFolder);
sca;
ShowCursor;
fclose('all'); %Not working Screen('CloseAll')%
Priority(0);
ListenChar(0);          % turn on keypresses -> command window

%% Restore PTB verbosity
Screen('Preference', 'Verbosity', oldLevelScreen);
PsychPortAudio('Verbosity', oldLevelAudio);

end
