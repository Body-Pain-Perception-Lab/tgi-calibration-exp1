function tgiMultiThreshold_main(vars, scr)
% TGI Multidimensional thresholding main function.
%
% Relies on the FAST toolbox, from Vul et al, 2010
% Publication available at https://www.evullab.org/pdf/s6.pdf
% Toolbox implementation available at https://github.com/edvul/FAST-matlab
%
% Project: Implementation of Multidimensional TGI Threshold estimation
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 21/07/2022

%% Load stimulation and task parameters
tgiMultiThreshold_loadParams;

%% Define Results struct
%%
uniqueFilename = strcat(vars.dir.OutputFolder,vars.ID.UniqueFileName,'.mat');

if ~exist(uniqueFilename)
    DummyDouble = ones(vars.task.NTrialsTotal,1).*NaN;
    DummyCell   = cell(size(DummyDouble));
    Results = struct('SubID',               {DummyDouble}, ...
                     'estimate',            {DummyCell}, ...
                     'myfast',              {DummyDouble}, ...
                     'tcsData',             {DummyCell}, ...
                     'targetTwarm',         {DummyDouble}, ...
                     'targetTcold',         {DummyDouble}, ...
                     'probability',         {DummyDouble}, ...
                     'param1_m',            {DummyDouble}, ...
                     'param1_se',           {DummyDouble}, ...
                     'param2_m',            {DummyDouble}, ...
                     'param2_se',           {DummyDouble}, ...
                     'param3_m',            {DummyDouble}, ...
                     'param3_se',           {DummyDouble}, ...
                     'S_m',                 {DummyDouble}, ...
                     'S_se',                {DummyDouble}, ...
                     'Response',            {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
                     'ReactionTime',        {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
                     'SOT_trial',           {DummyDouble}, ...%
                     'SOT_jitter',          {DummyDouble}, ...%
                     'SOT_stimOn',          {DummyDouble}, ...%
                     'SOT_stimOff',         {DummyDouble}, ...%
                     'SOT_ITI',             {DummyDouble}, ...%
                     'TrialDuration',       {DummyDouble}, ...%
                     'SessionStartT',       {DummyDouble}, ...
                     'SessionEndT',         {DummyDouble});%
else
    vars.ID.confirmedSubjN = input('Subject already exists. Do you want to continue anyway (yes = 1, no = 0)?    ');
    if vars.ID.confirmedSubjN 
        if vars.control.stimFlag
            com = vars.control.ser;
            load(uniqueFilename,'Results','vars','thisTrial')
            vars.control.ser=com; clear com
        else
            load(uniqueFilename,'Results','vars','thisTrial')
        end            
%         vars.control.startTrialN = input('Define the trial number to restart from?   ');
        vars.control.startTrialN = thisTrial;
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
     [scr]=openScreen(scr,vars);
   
    %% Dummy calls to prevent delays
    vars.control.RunSuccessfull = 0;
    vars.control.Aborted = 0;
    vars.control.Error = 0;
    vars.control.thisTrial = 1;
    [~, ~, keys.KeyCode] = KbCheck;
   
    
    %% Run through trials
    WaitSecs(0.5);            % pause before experiment start
    thisTrial = vars.control.startTrialN; % trial counter (user defined)
    Results.Response (thisTrial:end,:) = NaN; %Erase responses from defined trial onwards
     
    if thisTrial ~= 1
        Restarted = 1;   % If experiment was aborted, display thermode position in the first trial.
%         vars.fast.myfast = Results.myfast{thisTrial-1}; %removed to save space
        vars.fast.myfast = Results.myfast;
    else
        Restarted = 0;
    end
    endOfExpt = 0;
    
    %% Start session
    Results.SessionStartT = GetSecs;
    
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

        if thisTrial==1 %Always start the same. To avoid startup biases on the scaling procedure
            vars.fast.myfast = fastFull(vars.fast.nchoice, vars.fast.CurveFunc, vars.fast.PsyFunc, vars.fast.CurveParams);

            Tcold = 27;
            Twarm = 35;
            p = NaN;            
        else
            warmANDsafe = 0; 
            
            while ~warmANDsafe

%                 Tcold = randi(vars.task.Tcoldmax - vars.task.Tmin + 1)+vars.task.Tmin-1; %generates random temperatures between vars.task.Tmin and vars.task.Tcoldmax
%                 Tcold = 3*(randi(round((vars.task.Tcoldmax - vars.task.Tmin + 1)/3))+vars.task.Tmin-1); %generates random temperatures between vars.task.Tmin and vars.task.Tcoldmax
                Tcoldarray = vars.task.Tmin:3:vars.task.Tcoldmax;
                Tcoldarray = Tcoldarray(randperm(length((Tcoldarray))));
                Tcold =Tcoldarray(1);
%                 Tcold = vars.task.TcoldArray(thisTrial-1);
                p = randsample([0.25 0.5 0.75],1);
                Twarm = fastChooseYp(vars.fast.myfast, Tcold, p);

                if (Twarm<50) && (Twarm>vars.task.Tbaseline) %Safeguards: To ensure that participant won't be burned and that the warm temperature is always above baseline.
                    warmANDsafe=1;
                end
            end
        end
        
        Tcold=single(round(Tcold,1)); %Round values so it interfaces better with stimulator
        Twarm=single(round(Twarm,1));
        
        % trial starts
        Results.SOT_trial(thisTrial) = GetSecs - Results.SessionStartT; 
   
        % Draw Fixation
%         [~, ~] = Screen('Flip', scr.win);            % clear screen
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        scr = drawFixation(scr); % fixation point
        [~, ~] = Screen('Flip', scr.win);
        
        %% Jitter
        WaitSecs(vars.task.jitter(thisTrial));
          
        %% Stimulate
        vars.control.thisTrial =thisTrial;
        
        while any(isnan(Results.Response(thisTrial,find(vars.instructions.whichQuestion))))
            if vars.control.stimFlag
                [vars.control.stimTime,stimOn, stimOff, tcsData]  = stimulateVarDur(Results,scr,vars,keys,2,vars.stim.durationP,Tcold,Twarm); % Stimulate TGI
            else % Debug without stimulator
                disp('Debugging without the stimulator')
                vars.control.stimTime = tic;
                stimOn = NaN;
                stimOff = NaN;
                tcsData = NaN;
            end
            %%Brief feedback to experimenter
            disp(['Trial #' num2str(thisTrial) ', Twarm = ' num2str(Twarm) ', Tcold = ' num2str(Tcold)])
            
            %% Get Response
            for question_type_idx=1:length(vars.instructions.whichQuestion)
                if vars.instructions.whichQuestion(question_type_idx)==1
                    [Results.Response(thisTrial,question_type_idx),...
                        Results.ReactionTime(thisTrial,question_type_idx), vars] = getResponse(scr, vars,question_type_idx);
                else
                    Results.Response(thisTrial,question_type_idx) = NaN;
                    Results.ReactionTime(thisTrial,question_type_idx) = NaN;
                end
            end
            
            %% ITI
            if vars.control.stimFlag
                stimulatePulse(Results,scr,vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
            end
            Results.TrialDuration(vars.control.thisTrial) = GetSecs;
        end
        
        
        %% update FAST structure
        [vars.fast.myfast,resample] = fastUpdate(vars.fast.myfast, [Tcold Twarm Results.Response(thisTrial,1)]);
        if resample
            vars.fast.myfast = fastResample(vars.fast.myfast);
        end
        %store myfast struct
%         Results.myfast{thisTrial} = vars.fast.myfast; %removed to save space and speed things up
        Results.myfast = vars.fast.myfast;
        %%generate fast estimates
        Results.estimate{thisTrial} = fastEstimate(vars.fast.myfast, [0.25, 0.5 0.75],0, 1);
      
      
        %% Update Results
        Results.SubID(thisTrial)            = vars.ID.subNo;
        Results.tcsData {thisTrial}         = tcsData;
        Results.targetTwarm(thisTrial)      = Twarm;
        Results.targetTcold(thisTrial)      = Tcold;
        
        Results.probability(thisTrial)      = p;
        
        Results.param1_m(thisTrial)         = Results.estimate{thisTrial}.marg.mu(1);
        Results.param1_se(thisTrial)        = Results.estimate{thisTrial}.marg.sd(1);
        Results.param2_m(thisTrial)         = Results.estimate{thisTrial}.marg.mu(2);
        Results.param2_se(thisTrial)        = Results.estimate{thisTrial}.marg.sd(2);
        Results.param3_m(thisTrial)         = Results.estimate{thisTrial}.marg.mu(3);
        Results.param3_se(thisTrial)        = Results.estimate{thisTrial}.marg.sd(3);
        Results.S_m(thisTrial)              = 10^Results.estimate{thisTrial}.marg.mu(4);
        Results.S_se(thisTrial)             = Results.estimate{thisTrial}.marg.sd(4);
        
        Results.SOT_jitter(thisTrial)       = vars.task.jitter(thisTrial);
        Results.SOT_stimOn(thisTrial)       = stimOn;
        Results.SOT_stimOff(thisTrial)      = stimOff;
        Results.SOT_ITI(thisTrial)          = vars.task.ITI(thisTrial); 
        Results.SessionEndT                 = GetSecs  - Results.SessionStartT;
        
        %% Save Resampled parameters to increase precision
        if (thisTrial == vars.task.NTrialsTotal)
            
            %%Generate plots to see if space grids are good enough
            fastEstimate(vars.fast.myfast, [0.25, 0.5 0.75], 0,0);
            Results.estimate{thisTrial+1} = fastEstimate(vars.fast.myfast, [0.25, 0.5 0.75],1, 0);
            
            Results.param1_m(thisTrial+1)         = Results.estimate{thisTrial+1}.marg.mu(1);
            Results.param1_se(thisTrial+1)        = Results.estimate{thisTrial+1}.marg.sd(1);
            Results.param2_m(thisTrial+1)         = Results.estimate{thisTrial+1}.marg.mu(2);
            Results.param2_se(thisTrial+1)        = Results.estimate{thisTrial+1}.marg.sd(2);
            Results.param3_m(thisTrial+1)         = Results.estimate{thisTrial+1}.marg.mu(3);
            Results.param3_se(thisTrial+1)        = Results.estimate{thisTrial+1}.marg.sd(3);
            Results.S_m(thisTrial+1)              = 10^Results.estimate{thisTrial+1}.marg.mu(4);
            Results.S_se(thisTrial+1)             = Results.estimate{thisTrial+1}.marg.sd(4);
            
        end        
        %% save data at every trial
        %save(strcat(vars.OutputFolder, vars.UniqueFileName), 'Results', 'vars', 'scr', 'keys' );
        save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
        
        % Debugging termode temperature

% % for j=1:6
% 
% jj=thisTrial;
%     figure(1)
%     sgtitle(['Twarm = ' num2str(Results.targetTwarm(jj)) ' Tcold = ' num2str(Results.targetTcold(jj))])
%     for ii=1:5
%         subplot(3,2,ii)
%         plot(Results.tcsData{jj}(:,2+ii))
%         title(['Termode ' num2str(ii)])
%     end

        
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
