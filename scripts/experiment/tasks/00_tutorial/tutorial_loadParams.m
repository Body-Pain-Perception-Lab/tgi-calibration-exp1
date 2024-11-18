%% Define parameters
% Parameters file for Tutorial
% Project: Implementation of Multidimensional TGI Threshold estimation
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 21/07/2022

% %% Key flags
% vars.control.inputDevice    = 2;   % Response method for button presses 1 - mouse, 2 - keyboard 
% % If you are presenting stim in Up/Down you can only set this variable to 2
%% Fixed stimulation parameters

vars.stim.speed_ramp         = 100;   % rate of temperature change from baseline to target
vars.stim.return_ramp        = 100;   % rate of temperature change from target to baseline
vars.stim.durationP          = 2;    % Persistence How long to keep all temperatures at one level before stopping stimulation 
vars.stim.Ttol               = 0.21;  % Temperature Tolerance to start end of Stim counter
%% Task parameters

% Temperatures
vars.task.Tbaseline          = 30;   % baseline temperature
vars.task.TwarmArray         = [43:-1:35 35];
vars.task.TcoldArray         = 17:26;
vars.task.randTidx           = randperm(length(vars.task.TwarmArray));

%Trials
vars.task.NTrialsTotal       = length(vars.task.TwarmArray);  % Total number of trials
vars.task.NTrialsChangeP     = 3;   % Regularity that participant changes thermode position
vars.task.isVas              = [zeros(1,7) ones(1,vars.task.NTrialsTotal-7)];

%Times (in s)
vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 0.5; % this determines how long the feedbacks "button press detected" is shown on the screen
vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3.5; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;  % Time to respond

%% Instructions
vars.instructions.textSize = 35;

switch vars.control.language
    case 1 %English
        vars.instructions.Position = {'Please place the thermode in position 3.',...
                                       'Please place the thermode in position 1.',...
                                        'Please place the thermode in position 2.'};
        vars.instructions.Question = {'BURNING?\n \n \n YES - (L)                          NO - (R)',...
                                        'WARM-(U)\n \n \n \n \n \n Predominant? \n \n \n \n \n \n COLD - (D)',...
                                        'Please rate the most intense COLD sensation you felt.',...
                                        'Please rate the most intense WARM sensation you felt.',...
                                        'Please rate the most intense BURNING sensation you felt.'};

        vars.instructions.whichQuestion = [1 1 1 1 1]; % Array to enable or disable one of the questions in vars.instructions.Question


        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Yes' 'No';...
                                    'Warm' 'Cold'}; %First Feedback for 1. Then for 0.

        vars.instructions.Start = {'Please position the thermode to location 1. \n \n During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds. Afterwards we will ask you to answer two questions using the arrow keys: \n\n\n (1) Did you perceive a burning sensation? Yes = left arrow, No = right arrow \n (2) Was the sensation predominantly cold or warm? Cold = down arrow, Warm = up arrow  \n\n\n Try to respond as fast and as accurately as you can.\n \n \n \n  Press SPACE to start the task.',...
                                    'During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds and we will ask you to rate the most intense (1) cold, (2) warm and (3) burning sensation you felt, using 3 different scales.\n\n Please use the left/right arrow keys to select a point along the scale that matches the sensation described in the question. Press SPACE to confirm your answer\n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Not at all). \n \n \n \n  Press SPACE to start the task.'};

        %                                     'During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds and we will ask you to rate the most intense (1) cold, (2) warm and (3) burning sensation you felt, using 3 different scales.\n\n Please use the mouse to select a point along the scale that matches the sensation described in the question.\n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Not at all). \n \n \n \n  Press SPACE to start the task.'};

        vars.instructions.showS = [1 find(vars.task.isVas,1)]; % When to Show Start instructions
        vars.instructions.showE = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; % When to ask participant to change thermode position

        vars.instructions.ConfEndPoins = {'Not at all', 'Extreme'};
        
    case 2 %Danish
        
        vars.instructions.Position = {'Placer venligst termoden på lokation 3.',...
                                       'Placer venligst termoden på lokation 1.',...
                                        'Placer venligst termoden på lokation 2.'};
        vars.instructions.Question = {'BRÆNDENDE?\n \n \n JA - (V)                          NEJ - (H)',...
                                        'VARME-(O)\n \n \n \n \n \n Overvejende? \n \n \n \n \n \n KOLDE - (N)',...
                                        'Bedøm venligst den KOLDESTE fornemmelse du oplevede.',...
                                        'Bedøm venligst den VARMESTE fornemmelse du oplevede.',...
                                        'Bedøm venligst den MEST BRÆNDENDE fornemmelse du oplevede.'};

        vars.instructions.whichQuestion = [1 1 1 1 1]; % Array to enable or disable one of the questions in vars.instructions.Question


        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Ja' 'Nej';...
                                    'Varm' 'Kold'}; %First Feedback for 1. Then for 0.

        vars.instructions.Start = {'Placer venligst termoden på lokation 1. \n \n Under hver runde vil du opleve en temperaturændring (f.eks. nedkøling, opvarmning) i nogle sekunder. Derefter vil vi bede dig svare på to spørgsmål ved hjælp af piletasterne: \n\n\n (1) Oplevede du en brændende fornemmelse? Ja = venstre piletast, Nej = højre piletast \n (2) Var fornemmelsen overvejende kold eller varm? Kold = ned piletast, Varm = Op piletast  \n\n\n Svar så hurtigt og korrekt som du kan.\n \n \n \n  Tryk på MELLEMRUMSTASTEN for at starte opgaven.',...
                                    'Under hver runde vil du opleve en temperaturændring (f.eks. nedkøling, opvarmning) i nogle sekunder og vil vi bede dig bedømme den mest intense (1) kolde, (2) varme, og (3) brændende fornemmelse du opfattede ved hjælp af 3 skalaer. \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen der matcher fornemmelsen fra spørgsmålet bedst. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar. \n \n Hvis du ikke opfattede den sensation, som er beskrevet i spørgsmålet, vælg da den yderste venstre position (bedømmelse 0 = Overhovedet ikke). \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at starte opgaven.'};

        %                                     'During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds and we will ask you to rate the most intense (1) cold, (2) warm and (3) burning sensation you felt, using 3 different scales.\n\n Please use the mouse to select a point along the scale that matches the sensation described in the question.\n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Not at all). \n \n \n \n  Press SPACE to start the task.'};

        vars.instructions.showS = [1 find(vars.task.isVas,1)]; % When to Show Start instructions
        vars.instructions.showE = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; % When to ask participant to change thermode position

        vars.instructions.ConfEndPoins = {'Overhovedet ikke', 'Ekstremt'};
end
    