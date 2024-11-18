%% Define parameters
% Project: Multidimensional TGI Thresholding 
% Part 4: Threshold Rating Evaluation (VAS ratings)
%
% Camila Sardeto and Francesca Fardo
% Last edit: 21/07/2022

%% Key flags
                                                 
vars.control.inputDevice    = 2;   % Response method for button presses 1 - mouse, 2 - keyboard 
%% Fixed stimulation parameters

vars.stim.speed_ramp         = 100;   % rate of temperature change from baseline to target
vars.stim.return_ramp        = 100;   % rate of temperature change from target to baseline
vars.stim.durationP          = 2;    % Persistence How long to keep all temperatures at one level before stopping stimulation 
vars.stim.Ttol               = 0.21;  % Temperature Tolerance to start end of Stim counter

%% Equiprobable curve definition
vars.fast.pArray             = [0.25 0.5 0.75]; % Setting the probabilities of interest

%% Task parameters

%Trials
vars.task.gain               = [0.25 0.5 0.75]; % Gains defining where to sample the equiprobable curves
vars.task.granularity        = length(vars.task.gain); % How many points to sample on each equiprobable curve
vars.task.nRep               = 5; % How many times to sample each point
% vars.task.NTrialsTotal       = vars.task.granularity* vars.task.nRep * length(vars.fast.pArray)*3; % Total number of trials. Sampling for Cold, Warm and TGI
vars.task.NTrialsTotal       = length(vars.task.gain)* vars.task.nRep * length(vars.fast.pArray)*3; % Total number of trials. Sampling for Cold, Warm and TGI
vars.task.NTrialsChangeP     = 3; % Regularity that participant changes thermode position. If you don't want this, please make it equal to vars.task.NTrialsTotal 
vars.task.isIntenseLevel     = 0.7; % define level stimulus is considered intense, so they are not presented consecutevely 

%Times
vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 1; % this determines how long the feedbacks "button press detected" is shown on the screen
vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3.5; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond
% vars.task.breakT             = 30; %break for 30s


% indexing break
vars.task.isBreak = zeros(1,vars.task.NTrialsTotal);
vars.task.isBreak(vars.task.NTrialsTotal/vars.task.nRep:vars.task.NTrialsTotal/vars.task.nRep:vars.task.NTrialsTotal-1) = 1; % index trial where VAS should be presented

%% Temperatures: Loading Outcomes from previous Experiments
try
    
    try %Try loading data from this session. If not available, try session 1
        out1 = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-fasttgi_beh.mat'));
    catch
        out1 = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-fasttgi_beh.mat'));
    end
    
    vars.fast.myfast = out1.Results.myfast;
    if out1.thisTrial == out1.vars.task.NTrialsTotal
        vars.fast.myfast.params.est = out1.Results.estimate{end};
    else
        vars.fast.myfast.params.est = fastEstimate(vars.fast.myfast, [0.25, 0.5 0.75], 1,1); %so the code does not break if not all 100 trials from task 1 were collected
    end
    
    
   
    %Extract Twarm for the correspondent Tcold
    vars.task.Tbaseline = out1.vars.task.Tbaseline;

    vars.control.whichMethodCW = 1; %Use Psi (1) Method of Limits (2)
    [vars.task.TcoldTGI, vars.task.TwarmTGI,~,~]= computeTGItemps(vars,vars.task.gain,vars.fast.pArray); %Compute it such that we have three probability curves and 3 points in the valid interval
%     [vars.task.TcoldTGI, vars.task.TwarmTGI]= computeTemps(vars,vars.task.granularity,vars.fast.pArray); 

    %% Pseudorandomise array 
    % So intensly painful trials are not followed by another painful trial

    vars.task.TwarmSequence = [];
    vars.task.TcoldSequence = [];
    vars.task.TrialType     = [];
    vars.task.Intensity     = [];
        
    for r = 1:vars.task.nRep  
        [TwarmSequence, TcoldSequence, StimTypeSequence, IntensitySequence] = pseudorandomize_Block (vars);
        vars.task.TwarmSequence = [vars.task.TwarmSequence; TwarmSequence];
        vars.task.TcoldSequence = [vars.task.TcoldSequence; TcoldSequence];
        vars.task.TrialType     = [vars.task.TrialType; StimTypeSequence];
        vars.task.Intensity     = [vars.task.Intensity; IntensitySequence];
   
    end
  
    clear ('out1','TwarmSequence', 'TcoldSequence', 'StimTypeSequence', 'IntensitySequence')
catch
    error('Results from previous parts of the experiment are missing or with very few trials.')
end


%% Instructions
vars.instructions.textSize = 35;

switch vars.control.language
    case 1 %English

        vars.instructions.Position = {'Please place the thermode in position 3.',...
                                       'Please place the thermode in position 1.',...
                                        'Please place the thermode in position 2.'};

        vars.instructions.Question = {'Please rate the most intense COLD sensation you felt.',...
                                       'Please rate the most intense WARM sensation you felt.',...
                                       'Please rate the most intense BURNING sensation you felt.'}; 

        vars.instructions.whichQuestion = [1 1 1]; %Enable or disable question

        vars.instructions.Start = 'Please position the thermode to location 1. \n \n During each trial, you will perceive a temperature change (i.e., cooling, heating) for a few seconds and we will ask you to rate the most intense (1) cold, (2) warm and (3) burning sensation you felt, using 3 different scales.\n\n Please use the left/right arrow keys to select a point along the scale that matches the sensation described in the question. Press SPACE to confirm your answer. \n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Not at all).\n This task will last around 30-40 minutes.\n \n \n \n  Press SPACE to start the task.';
        
        vars.instructions.break = 'This is a short break. \n \n Please wait for the trial to begin again \n and do not move your arm from the thermal probe.';
        
        vars.instructions.breakEnd = 'Starting Again...';
        
        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position

        vars.instructions.ConfEndPoins = {'Not at all', 'Extreme'};

    case 2 %Danish
        
        vars.instructions.Position = {'Placer venligst termoden på lokation 3.',...
                                       'Placer venligst termoden på lokation 1.',...
                                        'Placer venligst termoden på lokation 2.'};

        vars.instructions.Question = {'Bedøm venligst den KOLDESTE fornemmelse du oplevede.',...
                                       'Bedøm venligst den VARMESTE fornemmelse du oplevede.',...
                                       'Bedøm venligst den MEST BRÆNDENDE fornemmelse du oplevede.'}; 

        vars.instructions.whichQuestion = [1 1 1]; %Enable or disable question

        vars.instructions.Start = 'Placer venligst termoden på lokation 1. \n \n Under hver runde vil du opleve en temperaturændring (f.eks. nedkøling, opvarmning) i nogle sekunder og vil vi bede dig bedømme den mest intense (1) kolde, (2) varme, og (3) brændende fornemmelse du opfattede ved hjælp af 3 skalaer. \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen der matcher fornemmelsen fra spørgsmålet bedst. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar.\n \n Hvis du ikke opfattede den sensation, som er beskrevet i spørgsmålet, vælg da den yderste venstre position (bedømmelse 0 = Overhovedet ikke). \n Denne opgave vil vare omkring 30 – 40 minutter.\n \n \n \n  Tryk på MELLEMRUMSTASTEN for at starte opgaven.';
        
        vars.instructions.break = 'This is a short break. \n \n Please wait for the trial to begin again \n and do not move your arm from the thermal probe.';
        
        vars.instructions.breakEnd = 'Starting Again...';
        
        vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position

        vars.instructions.ConfEndPoins = {'Overhovedet ikke', 'Ekstremt'};
end
