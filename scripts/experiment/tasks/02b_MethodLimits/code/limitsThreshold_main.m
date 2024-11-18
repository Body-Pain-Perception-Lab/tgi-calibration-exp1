function limitsThreshold_main(vars, scr)
% Project: Multidimensional TGI Thresholding
% Part 2: Cold/Warm Thresholding (Using Method of Limits)
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022

%% Load stimulation and task parameters
limitsThreshold_loadParams;

%% Define Results struct
%%
uniqueFilename = strcat(vars.dir.OutputFolder,vars.ID.UniqueFileName,'.mat');
if ~exist(uniqueFilename)
    DummyDouble = ones(vars.task.NTrialsTotal,1).*NaN;
    DummyCell   = cell(size(DummyDouble));
    
    Results = struct('SubID',           {DummyDouble}, ...
        'tcsData',         {DummyCell}, ...
        'thresholdRaw',    {DummyCell}, ...
        'thresholdMean',   {DummyCell}, ...
        'SOT_trial',       {DummyDouble}, ...
        'SOT_jitter',      {DummyDouble}, ...
        'SOT_stimOn',      {DummyDouble}, ...
        'SOT_stimOff',     {DummyDouble}, ...
        'SOT_ITI',         {DummyDouble}, ...
        'TrialDuration',   {DummyDouble}, ...
        'SessionStartT',   {DummyDouble}, ...
        'SessionEndT',     {DummyDouble});
    Results = eval(['cat(1,' repmat('Results, ', 1,length(vars.task.TrialStimArray)-1) , 'Results)']);
else
    vars.ID.confirmedSubjN = input('Subject already exists. Do you want to continue anyway (yes = 1, no = 0)?    ');
    if vars.ID.confirmedSubjN
        load(uniqueFilename,'Results')
        vars.control.startTrialN = input('Define the trial number to restart from?   ');
        vars.ID.date_time = datestr(now,'ddmmyyyy_HHMMSS');
        vars.ID.DataFileName =  strcat(vars.control.exptName, '_',vars.ID.subIDstring, '_', vars.ID.date_time);    % name of data file to write to
    else
        return
    end
end
%% Keyboard & keys configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;

%% Prepare to start
try
    %% Check if window is already open (if not, open screen window)
    [scr]=openScreen(scr, vars);
    
    
    %% Dummy calls to prevent delays
    vars.control.RunSuccessfull = 0;
    vars.control.Aborted = 0;
    vars.control.Error = 0;
    [~, ~, keys.KeyCode] = KbCheck;
    
    %% Run through trials
    
    WaitSecs(0.5);            % pause before experiment start
    thisTrial = vars.control.startTrialN; % trial counter (user defined)
    thisBlock = 1; % block counter (user defined)
    endOfExpt = 0;
    
    while endOfExpt ~= 1       % General stop flag for the loop
        for trialTypeIdx =1:length(vars.task.TrialStimArray)
            %% Start session
            Results(thisBlock).SessionStartT = GetSecs;
            
            %Ask participants about their beliefs
            storeTime = vars.task.RespT; %increase Response time for beliefs
            vars.task.RespT = vars.task.RespT*5;
            [Results(thisBlock).beliefStart, ~]= getVasRatings(keys, scr, vars,thisBlock+2); %Select cold and warm beliefs
            [~, ~, keys.KeyCode] = KbCheck;
            vars.task.RespT = storeTime;
            
            trialType = vars.task.TrialStimArray(trialTypeIdx); %gets type of stimulation
            endOfBlock = 0;
            
            while endOfBlock ~= 1
                %% show instructions
                if any(vars.instructions.show == thisTrial)
                    whichInstruction = find(vars.instructions.show == (thisBlock-1)*vars.task.NTrialsTotal+thisTrial);
                    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                    DrawFormattedText(scr.win, uint8([vars.instructions.Start{whichInstruction}]), 'center', 'center', scr.TextColour, 60); %#ok<FNDSB>
                    [~, ~] = Screen('Flip', scr.win);
                    
                    new_line;
                    disp(['Press SPACE to start ' vars.task.TrialName{thisBlock}]); new_line;
                    
                    [keys] = keyConfig();
                    while keys.KeyCode(keys.Space) == 0 % Wait for trigger
                        [~, ~, keys.KeyCode] = KbCheck;
                        WaitSecs(0.001);
                        
                        if keys.KeyCode(keys.Escape)==1 % if ESC, quit the experiment
                            % Save, mark the run
                            vars.control.RunSuccessfull = 0;
                            vars.control.Aborted = 1;
                            experimentEnd(vars, scr, keys, Results)
                            return
                        end
                    end
                end
                
                %% Trial starts: draw fixation point
                Results(thisBlock).SOT_trial(thisTrial) = GetSecs - Results(thisBlock).SessionStartT;
                
                disp(['Trial # ', num2str(thisTrial), ' ', vars.task.TrialName{thisBlock}]);
                
                % Draw Fixation
                %             [~, ~] = Screen('Flip', scr.win);            % clear screen
                Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                scr = drawFixation(scr); % fixation point
                [~, ~] = Screen('Flip', scr.win);
                
                %% Jitter
                WaitSecs(vars.task.jitter(thisBlock,thisTrial));
                
                %% Stimulate and get Response
                vars.control.thisTrial = thisTrial;
                if ~vars.control.stimFlag
                    disp('debugging without stimulation')
                    thresholdRaw = NaN;
                    thresholdMean = NaN;
                    vars.control.stimTime = tic;
                    stimOn = NaN;
                    stimOff = NaN;
                    tcsData = NaN;
                else
                    [thresholdRaw, thresholdMean, vars.control.stimTime,stimOn, stimOff, tcsData] = stimulateUntilPress(scr,vars,keys,trialType,vars.task.Tmin,vars.task.Tmax);
                    %% ITI
                    stimulatePulse(Results,scr,vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
                end
                
                Results(thisBlock).TrialDuration(vars.control.thisTrial) = GetSecs;
                
                %% Update Results
                Results(thisBlock).SubID(thisTrial)            = vars.ID.subNo;
                Results(thisBlock).tcsData {thisTrial}         = tcsData;
                Results(thisBlock).thresholdRaw{thisTrial}     = thresholdRaw;
                Results(thisBlock).thresholdMean{thisTrial}    = thresholdMean;
                Results(thisBlock).SOT_jitter(thisTrial)       = vars.task.jitter(thisBlock,thisTrial);
                Results(thisBlock).SOT_stimOn(thisTrial)       = stimOn;
                Results(thisBlock).SOT_stimOff(thisTrial)      = stimOff;
                Results(thisBlock).SOT_ITI(thisTrial)          = vars.task.ITI(thisBlock,thisTrial);
                Results(thisBlock).SessionEndT                 = GetSecs  - Results(thisBlock).SessionStartT;
                %% save data at every trial
                %save(strcat(vars.OutputFolder, vars.UniqueFileName), 'Results', 'vars', 'scr', 'keys' );
                save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
                
                
                %% Update trial/block counters
                
                if (thisTrial == vars.task.NTrialsTotal)
                    endOfBlock = 1;
                    
                    %Ask participants about their beliefs
                    storeTime = vars.task.RespT; %increase Response time for beliefs
                    vars.task.RespT = vars.task.RespT*5;
                    [Results(thisBlock).beliefEnd, ~]= getVasRatings(keys, scr, vars,thisBlock+2); %Select cold and warm beliefs
                    [~, ~, keys.KeyCode] = KbCheck;
                    vars.task.RespT = storeTime;
                    
                    save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
                    
                    if (trialTypeIdx == length(vars.task.TrialStimArray))
                        endOfExpt =1;
                    else
                        thisTrial = 1; %block finished, restart
                        thisBlock = thisBlock+1;
                    end
                else
                    thisTrial = thisTrial + 1; %Update trial number
                end
            end
        end
    end
    vars.control.RunSuccessfull = 1;
    
    % Save, mark the run
    experimentEnd(vars, scr, keys, Results);
    
    ShowCursor;
    
catch ME% Error. Clean up...
    
    % Save, mark the run
    vars.RunSuccessfull = 0;
    vars.Error = 1;
    experimentEnd(vars, scr, keys, Results);
    rethrow(ME)
end
