function psiThreshold_main(vars, scr)
% Project: Multidimensional TGI Thresholding 
% Parts 2 and 3: Cold/Warm Thresholding or TGI Thresholding (Using Psi - PALAMEDES) 
%
% Camila Sardeto Deolindo and Francesca Fardo
% Last edit: 21/07/2022

%% Load stimulation and task parameters
if vars.control.taskN ==0
    psiThreshold_loadParams_part0;
    vars.control.exptName = 'task-psiadap_beh';
elseif vars.control.taskN ==1
    if vars.control.whichBlock==0 %Cold 
        psiThreshold_loadParams_part10;
        vars.control.exptName = 'task-psidetcold_beh';
    elseif vars.control.whichBlock==1 %Warm
        psiThreshold_loadParams_part11;
        vars.control.exptName = 'task-psidetwarm_beh';
%     else
%         psiThreshold_loadParams_part1; %All
%         vars.control.exptName = 'task-psidet_beh';
    end
elseif vars.control.taskN ==2
   
    if vars.control.whichBlock==0 %Cold 
        psiThreshold_loadParams_part20;
        vars.control.exptName = 'task-psipaincold_beh';
    elseif vars.control.whichBlock==1 %Warm
        psiThreshold_loadParams_part21;
        vars.control.exptName = 'task-psipainwarm_beh';
    else
        psiThreshold_loadParams_part2; %All
        vars.control.exptName = 'task-psipain_beh';
    end
elseif vars.control.taskN==6
    psiThreshold_loadParams_part3;
    vars.control.exptName = 'task-psitgi_beh';
end

%% Define task specific vars 
vars.ID.date_time = datestr(now,'ddmmyyyy_HHMMSS');
vars.ID.DataFileName = strcat(vars.control.exptName, '_',vars.ID.subIDstring, '_', vars.ID.date_time);    % name of data file to write to
vars.ID.UniqueFileName =  strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_',vars.control.exptName);

uniqueFilename = strcat(vars.dir.OutputFolder,vars.ID.UniqueFileName,'.mat');
%% Define Results struct
%%
if ~exist(uniqueFilename)
    
    DummyDouble = ones(vars.task.NTrialsTotal,1).*NaN;
    DummyCell   = cell(size(DummyDouble));
    
    Results = struct('SubID',               {DummyDouble}, ...
        'PM',                   {DummyDouble},...%{DummyCell}, ...
        'tcsData',              {DummyCell}, ...
        'targetTwarm',          {DummyDouble}, ...
        'targetTcold',          {DummyDouble}, ...
        'Response',             {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
        'ReactionTime',         {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
        'threshold',            {DummyDouble}, ...
        'seThreshold',          {DummyDouble}, ...
        'slope',                {DummyDouble}, ...
        'seSlope',              {DummyDouble}, ...
        'SOT_trial',            {DummyDouble}, ...
        'SOT_jitter',           {DummyDouble}, ...
        'SOT_stimOn',           {DummyDouble}, ...
        'SOT_stimOff',          {DummyDouble}, ...
        'SOT_ITI',              {DummyDouble}, ...
        'TrialDuration',        {DummyDouble}, ...
        'SessionStartT',        {DummyDouble}, ...
        'SessionEndT',          {DummyDouble},...
        'UD',                   {DummyDouble});
    

    
    vars.control.startBlockN = 1;
    Results = eval(['cat(1,' repmat('Results, ', 1,length(vars.task.TrialStimArray)-1) , 'Results)']);
else
    vars.ID.confirmedSubjN = input('Subject already exists. Do you want to continue anyway (yes = 1, no = 0)?    ');
    if vars.ID.confirmedSubjN
        
        if vars.control.stimFlag
            com = vars.control.ser;
            load(uniqueFilename,'Results','vars')
            vars.control.ser=com; clear com
        else
            load(uniqueFilename,'Results','vars')
        end
        
%         vars.control.startTrialN = input('Define the trial number to restart from:   ');
%         vars.control.startBlockN = input('Define the block number to restart from:   ');
        
        vars.control.startBlockN = 1;
        vars.control.startTrialN = find(isnan(Results.Response(:,1)),1); %First nan
        
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
     [~, ~, keys.KeyCode] = KbCheck;
     
     %% Run through trials
     
     WaitSecs(0.5);            % pause before experiment start
     thisTrial = vars.control.startTrialN; % trial counter (user defined)
     thisBlock = vars.control.startBlockN; % block counter (user defined)
     
%      Results(thisBlock).Response (thisTrial:end,:) = NaN; %Erase responses from defined trial onwards
%      [Results(thisBlock+1:length(vars.task.TrialStimArray)).Response] = deal(NaN(size(Results(thisBlock).Response)));
%      
     if thisTrial ~= 1
         Restarted = 1;   % If experiment was aborted, display thermode position in the first trial.
%          PM = Results(thisBlock).PM{thisTrial};
         PM = Results(thisBlock).PM;
         try
             UD = Results(thisBlock).UD;
             StepSizeChangeCounter = max(UD.reversal);
             StepSizeDown = vars.updown.StepSizeDown{vars.task.TrialStimArray(thisBlock)+1};
             StepSizeUp = vars.updown.StepSizeUp{vars.task.TrialStimArray(thisBlock)+1};
         end
     else
         Restarted = 0;
         PM = vars.psi.PM{vars.task.TrialStimArray(thisBlock)+1};
         try 
             UD = vars.updown.UD{vars.task.TrialStimArray(thisBlock)+1};
             StepSizeChangeCounter = 1;
             StepSizeDown = vars.updown.StepSizeDown{vars.task.TrialStimArray(thisBlock)+1};
             StepSizeUp = vars.updown.StepSizeUp{vars.task.TrialStimArray(thisBlock)+1};
         end
     end
     endOfExpt = 0;
     
     while endOfExpt ~= 1       % General stop flag for the loop
         for trialTypeIdx =vars.control.startBlockN:length(vars.task.TrialStimArray)
             %% Start session
             Results(thisBlock).SessionStartT = GetSecs;
             
             trialType = vars.task.TrialStimArray(trialTypeIdx); %gets type of stimulation
             endOfBlock = 0;
             while endOfBlock ~= 1
                 
                 %% show instructions
                 if any(vars.instructions.show == thisTrial) || (Restarted ==1)
                     
                     Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                     if thisTrial ==1
                       
                        %Ask participants about their beliefs
                        if vars.control.taskN ==2
                          storeTime = vars.task.RespT; %increase Response time for beliefs
                          vars.task.RespT = vars.task.RespT*5;
                          [Results(thisBlock).beliefStart, ~]= getVasRatings(keys, scr, vars,thisBlock+2); %Select cold and warm beliefs
                          [~, ~, keys.KeyCode] = KbCheck;
                          vars.task.RespT = storeTime;
                        end
                        
                        %Instructions
                         DrawFormattedText(scr.win, uint8([vars.instructions.Start]), 'center', 'center', scr.TextColour, 60);
                         [~, ~] = Screen('Flip', scr.win);
                         
                         while keys.KeyCode(keys.Space) == 0 % Wait for trigger
                                 
                              [~, ~, keys.KeyCode] = KbCheck;
                              WaitSecs(0.001);
                         end
                         
                     else
                         [~,whichInstruction] = min(abs(thisTrial-vars.instructions.show));
                         whichInstruction = mod(whichInstruction,3)+1;
                         DrawFormattedText(scr.win, uint8([vars.instructions.Position{whichInstruction}]), 'center', 'center', scr.TextColour, 60); %#ok<FNDSB>
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
                 
                 vars.control.thisTrial =thisTrial;
                 
                 % Define temperatures
                 if thisTrial <= vars.task.NTrialsHab  %Habituation trials
                     if trialType==0 % cold
                         Tcold = UD.xCurrent;
                         Twarm = vars.task.Tbaseline;
                     elseif trialType==1 % warm
                         Tcold = vars.task.Tbaseline;
                         Twarm = UD.xCurrent;
                     else %TGI
                         Tcold = vars.task.TcoldTGI;
                         Twarm = UD.xCurrent;
                     end
                 else %Psi trials
                     
                     if trialType==0 % cold
                         Tcold = PM.xCurrent;
                         Twarm = vars.task.Tbaseline;
                     elseif trialType==1 % warm
                         Tcold = vars.task.Tbaseline;
                         Twarm = PM.xCurrent;
                     else %TGI
                         Tcold = vars.task.TcoldTGI;
                         Twarm = PM.xCurrent;
                     end
                 end
                 
                 Tcold=single(round(Tcold,1)); %Round values so it interfaces better with stimulator
                 Twarm=single(round(Twarm,1));
                 
                 
                 % trial starts
                 Results(thisBlock).SOT_trial(thisTrial) = GetSecs - Results(thisBlock).SessionStartT; 
                 
                 % Draw Fixation
%                  [~, ~] = Screen('Flip', scr.win);            % clear screen
                 Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                 scr = drawFixation(scr); % fixation point
                 [~, ~] = Screen('Flip', scr.win);
                 
                 %% Jitter
                 WaitSecs(vars.task.jitter(thisBlock,thisTrial));
                 %% Start Stimulation
                 % Psi-Adaptive
                                
                 while any(isnan(Results(thisBlock).Response(thisTrial,find(vars.instructions.whichQuestion))))
                     if vars.control.stimFlag
                         [vars.control.stimTime,stimOn, stimOff, tcsData] = stimulateVarDur(Results,scr,vars,keys,trialType,vars.stim.durationP,Tcold,Twarm); % Stimulate
                     else
                         disp('Debugging without stimulation')
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
                             [Results(thisBlock).Response(thisTrial,question_type_idx),...
                                 Results(thisBlock).ReactionTime(thisTrial,question_type_idx), vars] = getResponse(scr, vars,question_type_idx);
                         else
                             Results(thisBlock).Response(thisTrial,question_type_idx) = NaN;
                             Results(thisBlock).ReactionTime(thisTrial,question_type_idx) = NaN;
                         end
                     end
                     
                     %% ITI
                     if vars.control.stimFlag
                         stimulatePulse(Results,scr,vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
                     end
                     Results(thisBlock).TrialDuration(vars.control.thisTrial) = GetSecs;
                 end
                 
                 
                 if trialType ==0
                     response = 1 - Results(thisBlock).Response(thisTrial); %Invert results for compatibility
                 else
                     response = Results(thisBlock).Response(thisTrial); 
                 end
                 
                 %update PM based on response
                 if thisTrial > vars.task.NTrialsHab  %Don't save Habituation trials
                    PM = PAL_AMPM_updatePM(PM,response); %% This way is only valid for cold PF! For cold response is inverted. For warm it should be as it is
                                 
                     Results(thisBlock).threshold (thisTrial)       = PM.threshold(thisTrial-vars.task.NTrialsHab);
                     Results(thisBlock).seThreshold (thisTrial)     = PM.seThreshold(thisTrial-vars.task.NTrialsHab);
                     Results(thisBlock).slope(thisTrial)            = 10.^PM.slope(thisTrial-vars.task.NTrialsHab);%PM.slope is in log10 units of beta parameter
                     Results(thisBlock).seSlope(thisTrial)          = PM.seSlope(thisTrial-vars.task.NTrialsHab);
                     
                 else
                     UD = PAL_AMUD_updateUD(UD, response); %update UD structure
                                 
                     if UD.reversal(thisTrial) ~=0
                         StepSizeChangeCounter = StepSizeChangeCounter+1;
                         
                         if StepSizeChangeCounter>length(StepSizeUp)
                             idx = length(StepSizeUp);
                         else
                             idx = StepSizeChangeCounter;
                         end
                         UD = PAL_AMUD_setupUD(UD,'StepSizeDown',StepSizeDown(idx),'StepSizeUp', StepSizeUp(idx));
                         
                         Results(thisBlock).UD = UD;
                     end
                 end
                 
                  %store PM struct
%                  Results(thisBlock).PM {thisTrial}              = PM; %Not saving at every trial -- incredibly slow

                 %% Update Results
                 Results(thisBlock).PM                          = PM;
                 Results(thisBlock).SubID(thisTrial)            = vars.ID.subNo;
                 Results(thisBlock).tcsData {thisTrial}         = tcsData;
                 Results(thisBlock).targetTwarm(thisTrial)      = Twarm;
                 Results(thisBlock).targetTcold(thisTrial)      = Tcold;
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
                     if vars.control.taskN ==2
                         storeTime = vars.task.RespT; %increase Response time for beliefs
                         vars.task.RespT = vars.task.RespT*5;
                        [Results(thisBlock).beliefEnd, ~]= getVasRatings(keys, scr, vars,thisBlock+2); %Select cold and warm beliefs
                         [~, ~, keys.KeyCode] = KbCheck;
                         vars.task.RespT = storeTime;
                        save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
                     end

                     if (trialTypeIdx == length(vars.task.TrialStimArray))
                         endOfExpt =1;
                     else
                         thisTrial = 1; %block finished, restart
                         thisBlock = thisBlock+1; 
                         PM = vars.psi.PM{vars.task.TrialStimArray(thisBlock)+1};
                         UD = vars.updown.UD{vars.task.TrialStimArray(thisBlock)+1};
                     end
                 else
                     thisTrial = thisTrial + 1; %Update trial number
                 end
                 
             end
         end
     end     
     vars.control.RunSuccessfull = 1;
    %% 
     try %Added this to allow parts to be executed separately
         if vars.control.taskN ==1
             uniqueFilename = strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psidet_beh.mat');
             coldB = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psidetcold_beh.mat'));
             warmB = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psidetwarm_beh.mat'));
             Results = eval(['cat(1,' repmat('coldB.Results, ', 1,1) , 'warmB.Results)']);
             save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
         elseif vars.control.taskN ==2
             uniqueFilename = strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psipain_beh.mat');
             coldB = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psipaincold_beh.mat'));
             warmB = load(strcat(vars.dir.OutputFolder,'sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psipainwarm_beh.mat'));
             Results = eval(['cat(1,' repmat('coldB.Results, ', 1,1) , 'warmB.Results)']);
             save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );
         end
     catch
     end
     
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
