function tgiRating_main(vars, scr)
% Project: Multidimensional TGI Thresholding
% Part 4: Threshold Rating Evaluation (VAS ratings)
%
% Camila Sardeto and Francesca Fardo
% Last edit: 21/07/2022

%% Load the parameters
tgiRating_loadParams;

%% Define Results struct
uniqueFilename = strcat(vars.dir.OutputFolder,vars.ID.UniqueFileName,'.mat');

if ~exist(uniqueFilename)
    DummyDouble = ones(vars.task.NTrialsTotal,1).*NaN;
    DummyCell   = cell(size(DummyDouble));
    Results = struct('SubID',           {DummyDouble}, ...
        'tcsData',         {DummyCell}, ...
        'targetTwarm',     {DummyDouble}, ...
        'targetTcold',     {DummyDouble}, ...
        'vasResponse',     {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
        'vasReactionTime', {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
        'SOT_trial',       {DummyDouble}, ...
        'SOT_jitter',      {DummyDouble}, ...
        'SOT_stimOn',      {DummyDouble}, ...
        'SOT_stimOff',     {DummyDouble}, ...
        'SOT_ITI',         {DummyDouble}, ...
        'TrialDuration',   {DummyDouble}, ...
        'SessionStartT',   {DummyDouble}, ...
        'SessionEndT',     {DummyDouble});
else
    vars.ID.confirmedSubjN = input('Subject already exists. Do you want to continue anyway (yes = 1, no = 0)?    ');
    if vars.ID.confirmedSubjN
        com = vars.control.ser;
        load(uniqueFilename,'Results','vars')
        vars.control.ser=com; clear com
        vars.control.startTrialN = input('Define the trial number to restart from?   ');
        vars.ID.date_time = datestr(now,'ddmmyyyy_HHMMSS');
        vars.ID.DataFileName = strcat(vars.control.exptName, '_',vars.ID.subIDstring, '_', vars.ID.date_time);    % name of data file to write to
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
    vars.control.thisTrial = 1;
    vars.control.abortFlag = 0;
    [~, ~, keys.KeyCode] = KbCheck;
    
    %% Start session
    Results.SessionStartT = GetSecs;            % session start = trigger 1 + dummy vols
    
    %% Run through trials
    WaitSecs(0.500);            % pause before experiment start
    thisTrial = vars.control.startTrialN; % trial counter (user defined)
    Results.vasResponse (thisTrial:end,:) = NaN; %Erase responses from defined trial onwards
    
    endOfExpt = 0;
    if thisTrial ~= 1
        Restarted = 1;   % If experiment was aborted, display thermode position in the first trial.
    else
        Restarted = 0;
    end
    
    while endOfExpt ~= 1       % General stop flag for the loop
        
        %% show instructions
        if any(vars.instructions.show == thisTrial) || (Restarted ==1)
            
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            if thisTrial ==1
                DrawFormattedText(scr.win, uint8([vars.instructions.Start]), 'center', 'center', scr.TextColour, 60);
                [~, ~] = Screen('Flip', scr.win);
                
                while keys.KeyCode(keys.Space) == 0 % Wait for trigger
                    [~, ~, keys.KeyCode] = KbCheck;
                    WaitSecs(0.001);
                end
                
            else
                [~,whichInstruction] = min(abs(thisTrial-vars.instructions.show));
                whichInstruction = mod(whichInstruction,3)+1;
                DrawFormattedText(scr.win, uint8([vars.instructions.Position{whichInstruction}]), 'center', 'center', scr.TextColour, 60);
                [~, ~] = Screen('Flip', scr.win);
                WaitSecs(vars.task.movingT);
                
                Restarted = 0;
            end
            
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
            
            if keys.KeyCode(keys.Escape)==1 % if ESC, quit the experiment
                % Save, mark the run
                vars.control.RunSuccessfull = 0;
                vars.control.Aborted = 1;
                experimentEnd(vars, scr, keys, Results)
                return
            end
            
            new_line;
        end
        
        %% Trial starts: Configure temperatures and draw fixation point
        Tcold = single(round(vars.task.TcoldSequence(thisTrial),1)); %Round values so it interfaces better with stimulator
        Twarm = single(round(vars.task.TwarmSequence(thisTrial),1)); %Round values so it interfaces better with stimulator
        
        Results.SOT_trial(thisTrial) = GetSecs - Results.SessionStartT; % trial starts
        
        % Draw Fixation
        %         [~, ~] = Screen('Flip', scr.win);            % clear screen
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        scr = drawFixation(scr); % fixation point
        [~, ~] = Screen('Flip', scr.win);
        
        %% Jitter
        WaitSecs(vars.task.jitter(thisTrial));
        
        %% Stimulation ON
        vars.control.thisTrial = thisTrial;
        while any(isnan(Results.vasResponse(thisTrial,find(vars.instructions.whichQuestion))))
            
            if abs(Twarm-vars.task.Tbaseline)<0.01
                type = 0; %cold Trial
            elseif abs(Tcold-vars.task.Tbaseline)<0.01
                type = 1; %warm Trial
            else
                type = 2; %TGI trial
            end
            if vars.control.stimFlag
                [vars.control.stimTime,stimOn, stimOff, tcsData]  = stimulateVarDur(Results,scr,vars,keys,type,vars.stim.durationP,Tcold,Twarm); % Stimulate TGI
            else
                disp('Debugging without stimulation')
                vars.control.stimTime = tic;
                stimOn = NaN;
                stimOff = NaN;
                tcsData = NaN;
            end
            
            %%Brief feedback to experimenter
            disp(['Trial #' num2str(vars.control.thisTrial) ', Twarm = ' num2str(Twarm) ', Tcold = ' num2str(Tcold)])
            
            
            %% Get response: Ratings
            % Fetch the participant's ratings
            % randomize question order
            question_type_idx = randperm(length(vars.instructions.whichQuestion));
            
            for idx=1:length(question_type_idx)
                if vars.instructions.whichQuestion(question_type_idx(idx))==1
                    [Results.vasResponse(thisTrial,question_type_idx(idx)), ...
                        Results.vasReactionTime(thisTrial,question_type_idx(idx))]= getVasRatings(keys, scr, vars,question_type_idx(idx));
                else
                     Results.vasResponse(thisTrial,question_type_idx(idx)) = NaN;
                    Results.vasReactionTime(thisTrial,question_type_idx(idx)) = NaN;
                end
            end
            
            %% ITI
            if vars.control.stimFlag
                stimulatePulse(Results,scr,vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
            end
            Results.TrialDuration(vars.control.thisTrial) = GetSecs;
        end
        
        %% Break
        if vars.task.isBreak(thisTrial) == 1
            DrawFormattedText(scr.win, uint8([vars.instructions.break]), 'center', 'center', scr.TextColour, 60);
            [~, ~] = Screen('Flip', scr.win);
            
            WaitSecs(0.001);
            while keys.KeyCode(keys.Space) == 0 % Wait for trigger - No longer a fixed break
                [~, ~, keys.KeyCode] = KbCheck;
                WaitSecs(0.001);
            end
            
            DrawFormattedText(scr.win, uint8([vars.instructions.breakEnd]), 'center', 'center', scr.TextColour, 60);
            [~, ~] = Screen('Flip', scr.win);
            WaitSecs(5);
            
            
%             DrawFormattedText(scr.win, uint8([vars.instructions.break]), 'center', 'center', scr.TextColour, 60);
%             [~, ~] = Screen('Flip', scr.win);
%             WaitSecs(vars.task.breakT-1);
%             DrawFormattedText(scr.win, uint8([vars.instructions.breakEnd]), 'center', 'center', scr.TextColour, 60);
%             [~, ~] = Screen('Flip', scr.win);
%             WaitSecs(1);
        end
        
        %% Update Results
        Results.SubID(thisTrial)        = vars.ID.subNo;
        Results.tcsData{thisTrial}      = tcsData;
        Results.targetTwarm(thisTrial)  = Twarm;
        Results.targetTcold(thisTrial)  = Tcold;
        Results.SOT_jitter(thisTrial)   = vars.task.jitter(thisTrial);
        Results.SOT_stimOn(thisTrial)   = stimOn;
        Results.SOT_stimOff(thisTrial)  = stimOff;
        Results.SOT_ITI(thisTrial)      = vars.task.ITI(thisTrial);
        Results.SessionEndT             = GetSecs  - Results.SessionStartT;
        
        %% save data at every trial
        %save(strcat(vars.OutputFolder, vars.UniqueFileName), 'Results', 'vars', 'scr', 'keys' );
        save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
        
        
        %% Continue to next trial or time to stop? (max # trials reached)
        if (thisTrial == vars.task.NTrialsTotal)
            endOfExpt = 1;
        else
            % Advance one trial
            thisTrial = thisTrial + 1;
        end
        
    end % end trial
    
    
    vars.control.RunSuccessfull = 1;
    
    % Save, mark the run
    experimentEnd(vars, scr, keys, Results);
    
    ShowCursor;
    
    
catch ME% Error. Clean up...
    
    % Save, mark the run
    vars.control.RunSuccessfull = 0;
    vars.control.Error = 1;
    experimentEnd(vars, scr, keys, Results);
    rethrow(ME)
end