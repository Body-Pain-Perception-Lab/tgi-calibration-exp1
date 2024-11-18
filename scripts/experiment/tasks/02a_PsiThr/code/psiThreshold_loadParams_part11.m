%% Define parameters
%
% Project: Multidimensional TGI Thresholding 
% Part 2: Warm Pain Thresholding (Psi)
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022
%% Key flags
                                                 
vars.control.inputDevice    = 2;   % Response method for button presses 1 - mouse, 2 - keyboard 
% Response method for button presses 1 - mouse, 2 - keyboard 
% If you are presenting stim in Up/Down you shall set this variable to 2
%% Fixed stimulation parameters

vars.stim.speed_ramp         = 100;   % rate of temperature change from baseline to target
vars.stim.return_ramp        = 100;   % rate of temperature change from target to baseline
vars.stim.durationP          = 2;    % Persistence How long to keep all temperatures at one level before stopping stimulation 
vars.stim.Ttol               = 0.21;  % Temperature Tolerance to start end of Stim counter

%% Task parameters

% Temperatures
vars.task.Tbaseline          = 30;   % baseline temperature
vars.task.Tcoldmax           = 29.9;   % Highest limit of cold temperatures
vars.task.Twarmmin           = 30.1;   % Highest limit of cold temperatures
vars.task.Tmin               = 15;    % Lowest temperature limit 
vars.task.Tmax               = 42;   % Highest temperature limit 

%Trials
vars.task.NTrialsTotal       = 30; %50 % Total number of trials (It DOES include the habituation trials), so the total number of trials in Psi is this value subtracted by vars.task.NTrialsHab 
vars.task.NTrialsChangeP     = 3; % Regularity that participant changes thermode position

% Habituation trials, so the participant gets used to the intensity of the stimuli.
vars.task.NTrialsHab         = 0; %Number of habituation trials - Put 0 if you don't want this option

% Sequence
vars.task.TrialStimArray     = [1];% 0=cold, 1=warm, 2=TGI

%Times
vars.task.jitter             = randInRange(1,3,[length(vars.task.TrialStimArray),vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 1; % this determines how long the feedbacks "button press detected" is shown on the screen
vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3.5; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond
        
%% Psi parameters : Setting Up Palamedes

vars.psi.StimArray{1}       = vars.task.Tmin:0.1:vars.task.Tcoldmax;  % Temperature range for cold stimuli (in oC)
vars.psi.StimArray{2}       = vars.task.Twarmmin:0.1:vars.task.Tmax; % Temperature range for warm stimuli (in oC)
% vars.psi.StimArray{3}       = vars.task.Tbaseline:0.1:vars.task.Tmax; % Temperature range for TGI stimuli (in oC) - assuming fixed cold
vars.psi.StimArray{3}       = max(15, vars.task.Tmin):0.1:vars.task.Tmax; % Temperature range for TGI stimuli (in oC) - assuming fixed cold

vars.psi.PriorGrain = 50; %grain of posterior, high numbers make method more precise at the cost of RAM and time to compute.
%Always check posterior after method completes [using e.g., :image(PAL_Scale0to1(PM.pdf)*64) to check whether appropriate
%grain and parameter ranges were used.
vars.psi.PF = @PAL_CumulativeNormal; %assumed psychometric function

%Define parameter ranges to be included in posterior
% 1=cold 2=warm 3-TGI
vars.psi.priorAlphaRange = cellfun(@(x) linspace(min(x),max(x),vars.psi.PriorGrain),vars.psi.StimArray,'UniformOutput',false);
vars.psi.priorBetaRange =  linspace(log10(0.001),log10(6),vars.psi.PriorGrain); %Use log10 transformed values of beta (slope) parameter in PF
vars.psi.priorGammaRange = 0.05;  %fixed value (using vector here would make it a free parameter)
vars.psi.priorLambdaRange = 0.05;

%Initialize PM structure
%1=cold, 2=warm
vars.psi.PM = cellfun(@(x,y) PAL_AMPM_setupPM('priorAlphaRange',x,...
    'priorBetaRange',vars.psi.priorBetaRange,...
    'priorGammaRange',vars.psi.priorGammaRange,...
    'priorLambdaRange',vars.psi.priorLambdaRange,...
    'numtrials',vars.task.NTrialsTotal,...
    'PF' , vars.psi.PF,...
    'stimRange',y),...
    vars.psi.priorAlphaRange,...
    vars.psi.StimArray,...
    'UniformOutput',false);
%'marginalize','lapse');

%% Setting Up habituation using N-Down
vars.updown.up = 1;  %increase after 1 wrong
vars.updown.down = 1; %decrease after 1 right 

% Cold Setup
vars.updown.StepSizeDown{1} = [5 4 3 2 1]; 
vars.updown.StepSizeUp{1} = [2 2 2 2 2]; % Step size 
vars.updown.xmax{1} = vars.task.Tcoldmax;
vars.updown.xmin{1} = vars.task.Tmin;
vars.updown.startvalue{1} = 20;  

% Warm Setup
vars.updown.StepSizeDown{2} = [2 2 2];
vars.updown.StepSizeUp{2} = [3 2 1]; % Step size 
vars.updown.xmax{2} = vars.task.Tmax;
vars.updown.xmin{2} = vars.task.Twarmmin;
vars.updown.startvalue{2} = 38;             % Start Temp for warm array

% TGI Setup
vars.updown.StepSizeDown{3} = [2 2 2];
vars.updown.StepSizeUp{3} = [3 2 1]; % Step size 
vars.updown.xmax{3} = vars.task.Tmax;
vars.updown.xmin{3} = vars.task.Twarmmin;
vars.updown.startvalue{3} = 35; 

try 
    vars.updown.UD = cellfun(@(x,y,z,w,k) PAL_AMUD_setupUD('up',vars.updown.up,'down',vars.updown.down,...
    'StepSizeDown',x(1),'StepSizeUp', y(1),'stopcriterion','trials','stoprule',vars.task.NTrialsHab, ...
    'startvalue',z,'xmin',w,'xmax',k),...,
    vars.updown.StepSizeDown,vars.updown.StepSizeUp,vars.updown.startvalue,vars.updown.xmin,vars.updown.xmax,'UniformOutput',false);

end
               
%% Instructions
vars.instructions.textSize = 35;

switch vars.control.language
    case 1 %English
        vars.instructions.Position = {'Please place the thermode in position 3.',...
                                       'Please place the thermode in position 1.',...
                                        'Please place the thermode in position 2.'};

         vars.instructions.Question = {'WARM?\n \n \n YES - (L)                          NO - (R)',...
                                       'WARM-(U)\n \n \n \n \n \n Predominant? \n \n \n \n \n \n COLD - (D)',...
                                       'How sensitive do you think you are to WARM pain?\n\n Please use the left/right arrow keys to select a point along the scale. Press SPACE to confirm your answer. \n \n',...
                                       'How sensitive do you think you are to COLD pain?\n\n Please use the left/right arrow keys to select a point along the scale. Press SPACE to confirm your answer. \n \n'};                            
        vars.instructions.whichQuestion = [1 0 0 0]; %Enable or disable question

        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Yes' 'No';...
                                    'Warm' 'Cold'}; %First Feedback for 1. Then for 0.

        vars.instructions.ConfEndPoins = {'Not at all', 'Extreme'};

        vars.instructions.Start = 'Please position the thermode to location 1. \n \n During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds. Afterwards we will ask you to answer one question using the arrow keys: \n (1) Did you perceive a WARM sensation? Yes = left arrow, No = right arrow \n\n\n Try to respond as fast and as accurately as you can.\n This task will take 5-10 minutes. \n \n \n  Press SPACE to start the task.';

        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position
    
    case 2 %Danish
        vars.instructions.Position = {'Placer venligst termoden på lokation 3.',...
                                       'Placer venligst termoden på lokation 1.',...
                                        'Placer venligst termoden på lokation 2.'};

        vars.instructions.Question = {'VARME?\n \n \n JA - (V)                          NEJ - (H)',...
                                       'VARME-(O)\n \n \n \n \n \n Overvejende? \n \n \n \n \n \n KOLDE - (N)',...
                                       'Hvor følsom tror du, at du er over for VARMESMERTER? \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar.\n \n',...
                                       'Hvor følsom tror du, at du er over for KULDESMERTER? \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar.\n \n'};                            
        vars.instructions.whichQuestion = [1 0 0 0]; %Enable or disable question

        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Ja' 'Nej';...
                                    'Varm' 'Kold'}; %First Feedback for 1. Then for 0.

        vars.instructions.ConfEndPoins = {'Overhovedet ikke', 'Ekstremt'};

        vars.instructions.Start = 'Placer venligst termoden på lokation 1. \n \n Under hver runde vil du opleve en temperaturændring (f.eks. nedkøling, opvarmning) i nogle sekunder. Derefter vil vi bede dig svare på et spørgsmål ved hjælp af piletasterne: \n (1) Oplevede du en VARME fornemmelse? Ja = venstre piletast, Nej = højre piletast \n\n\n Svar så hurtigt og korrekt som du kan. \n Denne opgave varer ca. 5-10 minutter. \n \n \n  Tryk på MELLEMRUMSTASTEN for at starte opgaven.';

        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position
end