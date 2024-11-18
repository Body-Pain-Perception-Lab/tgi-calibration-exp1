%% Define parameters
%
% Project: Implementation of Multidimensional TGI Threshold estimation -
% Part 2: method of Limits
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 07/02/2022

%% Key flags
vars.control.inputDevice    = 2;   % Response method for button presses 1 - mouse, 2 - keyboard 

%% Fixed stimulation parameters

vars.stim.speed_ramp         = 1;   % rate of temperature change from baseline to target
vars.stim.return_ramp        = 1;   % rate of temperature change from target to baseline
vars.stim.durationS          = 32;    % max stimulation duration
%% Task parameters

% Temperatures
vars.task.Tbaseline          = 30;   % baseline temperatur
vars.task.Tmin               = 0;    % Lowest temperature limit 
vars.task.Tmax               = 50;   % Highest temperature limit 

% Sequence
vars.task.TrialStimArray     = [0 1];% 0=cold, 1=warm, 2=TGI

%Trials
vars.task.NTrialsTotal           = 10; % Total number of trials per block

%Times
vars.task.jitter             = randInRange(1,3,[length(vars.task.TrialStimArray),vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 1; % this determines how long the feedbacks "button press detected" is shown on the screen
vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3.5; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond

% Generate array of names for display purposes
vars.task.TrialName          = cell(size(vars.task.TrialStimArray));
vars.task.TrialName(vars.task.TrialStimArray==0)  = {'Cold'};
vars.task.TrialName(vars.task.TrialStimArray==1)  = {'Warm'};
vars.task.TrialName(vars.task.TrialStimArray==2)  = {'TGI'};

%% Instructions
vars.instructions.textSize = 35;
switch vars.control.language
    case 1 %English
        vars.instructions.FeedbackBP = {'Trial ended. Threshold is outside the tested temperature range.',...
                                        'Button press detected'};

        vars.instructions.Question = {'BURNING?\n \n \n YES - (L)                          NO - (R)',...
                                       'WARM-(U)\n \n \n \n \n \n Predominant? \n \n \n \n \n \n COLD - (D)',...
                                       'How sensitive do you think you are to COLD pain?\n\n Please use the left/right arrow keys to select a point along the scale. Press SPACE to confirm your answer. \n \n',...
                                       'How sensitive do you think you are to WARM pain?\n\n Please use the left/right arrow keys to select a point along the scale. Press SPACE to confirm your answer. \n \n'};                            
        vars.instructions.whichQuestion = [0 0 0 0]; %Enable or disable question
        vars.instructions.ConfEndPoins = {'Not at all', 'Extreme'};
        
        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Yes' 'No';...
                                    'Warm' 'Cold'}; %First Feedback for 1. Then for 0.


        vars.instructions.Start = {'Please position the thermode to location 1 \n \n We will test when you perceive painfully cold sensations. Your skin will be slowly cooled. At some point in time you will feel a second sensation on top of the cold sensation. The impression of cold will change its quality towards an additional impression of a burning, stinging, drilling or aching sensation. Please press the SPACE as soon as you perceive such a change. Please do not wait until the sensation has become unbearably painful. \n \n \n \n  Press SPACE to continue.', ... 
                             'Please press the SPACE as soon as the cold sensation changes its quality to an additional burning, stinging, drilling or aching sensation. \n \n This will be repeated several times. \n \n \n \n  Press SPACE to continue.', ... 
                             'Please position the thermode to location 2 \n \n Now we will test when you perceive painfully warm or heat sensations. Your skin will be slowly warmed. At some point in time you will feel a second sensation on top of the warm or heat sensation. The impression of warm/heat will change its quality towards an additional impression of a burning, stinging, drilling or aching sensation. Please press the SPACE as soon as you perceive such a change. Please do not wait until the sensation has become unbearably painful. \n \n \n \n  Press SPACE to continue.',...
                             'Please press the SPACE as soon as the warm or heat sensation changes its quality to an additional burning, stinging, drilling or aching sensation. \n \n This will be repeated several times. \n \n \n \n Press SPACE to continue.',...
                             'Please position the thermode to location 3 \n \n Now we will test when you perceive painful sensations again. Your skin will be slowly cooled or warmed. At some point in time you will feel a second sensation on top of a cold, warm or heat sensation. The impression of cold, warmth or heat will change its quality towards an additional impression of a burning, stinging, drilling or aching sensation. Please press the SPACE as soon as you perceive such a change. Please do not wait until the sensation has become unbearably painful. \n \n \n \n  Press SPACE to continue.',...
                             'Please press the SPACE as soon as the cold or heat sensation changes its quality to an additional burning, stinging, drilling or aching sensation. \n \n This will be repeated several times. \n \n \n \n Press SPACE to continue.'};        

        vars.instructions.show    = sort([1:vars.task.NTrialsTotal:vars.task.NTrialsTotal*length(vars.task.TrialStimArray) 2:vars.task.NTrialsTotal:vars.task.NTrialsTotal*length(vars.task.TrialStimArray)]); % When to present instructions

    case 2 %Danish
        
        vars.instructions.FeedbackBP = {'Denne del er slut. Grænseværdinen er udenfor den testede temperaturrækkevidde.',...
                                        'Dit tryk på knappen er registreret.'};

                                    
        vars.instructions.Question = {'BRÆNDENDE?\n \n \n JA - (V)                          NEJ - (H)',...
                                       'VARME-(O)\n \n \n \n \n \n Overvejende? \n \n \n \n \n \n KOLDE - (N)',...
                                       'Hvor følsom tror du, at du er over for KULDESMERTER? \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar.\n \n',...
                                       'Hvor følsom tror du, at du er over for VARMESMERTER? \n\n Benyt venligst den venstre/højre piletast til at vælge det punkt på skalaen. Tryk på MELLEMRUMSTASTEN for at bekræfte dit svar.\n \n'};                            
        vars.instructions.whichQuestion = [0 0 0 0]; %Enable or disable question
        vars.instructions.ConfEndPoins = {'Overhovedet ikke', 'Ekstremt'};
        
        vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
        vars.instructions.Feedback ={'Ja' 'Nej';...
                                    'Varm' 'Kold'}; %First Feedback for 1. Then for 0.

        vars.instructions.Start = {'Placer venligst termoden på lokation 1 \n \n Vi vil teste hvornår du opfatte smertefuld kulde fornemmelser. Din hud vil blive langsomt nedkølet. På et tidspunkt vil du fornemme en anden følelse udover kulden. Fornemmelsen af kulden vil ændresin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. Tryk venligst på den MELLEMRUMSTASTEN  lige så snart du oplever en sådan ændring. Vent ikke til fornemmelsen er blevet uudholdeligt smertefuld. \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at fortsætte', ... 
                             'Tryk venligst på den MELLEMRUMSTASTEN  så snart den kolde fornemmelse ændrer sin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. \n \n Dette vil gentages adskillige gange. \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at fortsætte', ... 
                             'Placer venligst termoden på lokation 2 \n \n Vi vil teste hvornår du opfatte smertefuld varme fornemmelser. Din hud vil blive langsomt varmet. På et tidspunkt vil du fornemme en anden følelse udover varmen. Fornemmelsen af varmen vil ændresin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. Tryk venligst på den MELLEMRUMSTASTEN  lige så snart du oplever en sådan ændring. Vent ikke til fornemmelsen er blevet uudholdeligt smertefuld. \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at fortsætte', ... 
                             'Tryk venligst på den MELLEMRUMSTASTEN  så snart den varme fornemmelse ændrer sin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. \n \n Dette vil gentages adskillige gange. \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at fortsætte', ... 
                             'Placer venligst termoden på lokation 3 \n \n Nu vil vi teste hvornår du opfatter den smertefulde fornemmelse igen. Din hud vil blive kølet eller varmet. På et tidspunkt vil du fornemme en anden følelse udover kulden eller varmen. Fornemmelsen af kulden eller varmen vil ændre sin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. Tryk venligst på den MELLEMRUMSTASTEN  lige så snart du oplever en sådan ændring. Vent ikke til fornemmelsen er blevet uudholdeligt smertefuld. \n \n \n \n  Tryk på MELLEMRUMSTASTEN for at fortsætte', ... 
                             'Tryk venligst på den MELLEMRUMSTASTEN  så snart den kolde eller varme fornemmelse ændrer sin kvalitet imod også at indeholde en brændende, stikkende, borende eller en øm fornemmelse. \n \n Dette vil gentages adskillige gange. \n \n \n \n Tryk på MELLEMRUMSTASTEN for at fortsætte'};        

        vars.instructions.show    = sort([1:vars.task.NTrialsTotal:vars.task.NTrialsTotal*length(vars.task.TrialStimArray) 2:vars.task.NTrialsTotal:vars.task.NTrialsTotal*length(vars.task.TrialStimArray)]); % When to present instructions

end