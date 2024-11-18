%% Define parameters
% parameters TGI Multidimensional Thresholding (FAST)
% Project: Implementation of Multidimensional TGI Threshold estimation
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 21/07/2022

%% Key flags
vars.control.inputDevice    = 2;   % Response method for button presses 1 - mouse, 2 - keyboard 
% If you are presenting stim in Up/Down you can only set this variable to 2
%% Fixed stimulation parameters

vars.stim.speed_ramp         = 100;   % rate of temperature change from baseline to target
vars.stim.return_ramp        = 100;   % rate of temperature change from target to baseline
vars.stim.durationP          = 2;    % Persistence How long to keep all temperatures at one level before stopping stimulation 
vars.stim.Ttol               = 0.21;  % Temperature Tolerance to start end of Stim counter
%% Multidimensional parameters : Setting Up FAST

% 0 - matching 1- detection 2- n-alternative forced choice
vars.fast.nchoice = 1;  

% CurveFunc: string specifying the name of the psychometric function
vars.fast.PsyFunc = 'psyLogistic';  

% CurveFunc: string specifying the name of the threshold function
vars.fast.CurveFunc = 'funcTVC_new';

% CurveParams is a cell array specifying the initial estimates of each 
% parameter of CurveFunc, and the width/slope of the psychometric function
% If negative values are possible- linear. Else logaritmic (log10)
vars.fast.CurveParams = {[0 30 10],[0 50 10],[0 4],[0.001 20]};

%% Task parameters

% Temperatures
vars.task.Tbaseline          = 30;   % baseline temperature
vars.task.Tmin               = 0;    % Lowest temperature limit 
vars.task.Tcoldmax           = 30;   % Highest limit of cold temperatures
vars.task.Tmax               = 50;   % Highest temperature limit 
% vars.task.TcoldArray         = repmat((vars.task.Tmin:vars.task.Tcoldstep:vars.task.Tcoldmax),1,vars.task.TnRep); 
%     idx=randperm(length(vars.task.TcoldArray));
%     vars.task.TcoldArray     = vars.task.TcoldArray(idx); clear idx;

% Trials
vars.task.NTrialsTotal       = 100;  % Total number of trials %+1 because we're fixatng the first trial
vars.task.NTrialsChangeP     = 3;   % Regularity that participant changes thermode position

% Times (in s)
vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 1; % this determines how long the feedbacks "button press detected" is shown on the screen
vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3.5; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond

%% Instructions
vars.instructions.textSize = 35;

switch vars.control.language
    case 1 %English

        vars.instructions.Position = {'Please place the thermode in position 3.',...
                                       'Please place the thermode in position 1.',...
                                        'Please place the thermode in position 2.'};

        vars.instructions.Question = {'BURNING?\n \n \n YES - (L)                          NO - (R)',...
                                       'WARM-(U)\n \n \n \n \n \n Predominant? \n \n \n \n \n \n COLD - (D)'}; 

        vars.instructions.whichQuestion = [1 1];  % Array to enable or disable one of the questions in vars.instructions.Question

        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Yes' 'No';...
                                    'Warm' 'Cold'}; %First Feedback for 1. Then for 0.


        vars.instructions.Start = 'Please position the thermode to location 1. \n \n During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds. Afterwards we will ask you to answer two questions using the arrow keys: \n\n\n (1) Did you perceive a burning sensation? Yes = left arrow, No = right arrow \n (2) Was the sensation predominantly cold or warm? Cold = down arrow, Warm = up arrow  \n\n\n Try to respond as fast and as accurately as you can.\n This task will take around 30-35 minutes.\n \n \n \n  Press SPACE to start the task.';

        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position
        
        
    case 2 %Danish
        vars.instructions.Position = {'Placer venligst termoden på lokation 3.',...
                                       'Placer venligst termoden på lokation 1.',...
                                        'Placer venligst termoden på lokation 2.'};

        vars.instructions.Question = {'BRÆNDENDE?\n \n \n JA - (V)                          NEJ - (H)',...
                                       'VARME-(O)\n \n \n \n \n \n Overvejende? \n \n \n \n \n \n KOLDE - (N)'}; 

        vars.instructions.whichQuestion = [1 1];  % Array to enable or disable one of the questions in vars.instructions.Question

        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Ja' 'Nej';...
                                    'Varm' 'Kold'}; %First Feedback for 1. Then for 0.


        vars.instructions.Start = 'Placer venligst termoden på lokation 1. \n \n Under hver runde vil du opleve en temperaturændring (f.eks. nedkøling, opvarmning) i nogle sekunder. Derefter vil vi bede dig svare på to spørgsmål ved hjælp af piletasterne: \n\n\n (1) Oplevede du en brændende fornemmelse? Ja = venstre piletast, Nej = højre piletast \n (2) Var fornemmelsen overvejende kold eller varm? Kold = ned piletast, Varm = Op piletast \n\n\n Svar så hurtigt og korrekt som du kan. \n Denne opgave varer ca. 30-35 minutter.\n \n \n \n Tryk på MELLEMRUMSTASTEN for at starte opgaven.';
        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position
end
    