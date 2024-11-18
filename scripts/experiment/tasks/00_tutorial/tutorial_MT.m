function tutorial_MT(scr,vars)
% Runs a tutorial for the Multidimensional Threshold estimation tasks
%
% Project: Implementation of Multidimensional TGI Threshold estimation
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 21/07/2022

%% Do checks 
if vars.control.stimFlag
    ser = TcsCheckStimulator(vars);
    vars.control.ser = ser;
else
    disp ('No stimulator, tutorial finished')
    return
end
vars.control.startTask =tic;
%% Load stimulation and task parameters
tutorial_loadParams;

%% Keyboard & screen configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;

%% Prepare to start
%  try
    %% Open screen 
    [scr]=openScreen(scr, vars);
   
    
    %% Dummy calls to prevent delays
    [~, ~, keys.KeyCode] = KbCheck;
    Response = NaN(length(vars.task.TcoldArray),length(vars.instructions.whichQuestion));
    Results = [];
    %% Run through trials
    WaitSecs(0.5);            % pause before experiment start
    endOfExpt = 0;
    thisTrial = 1;
    
    %% Start session
    
    while endOfExpt ~= 1       % General stop flag for the loop
        
        %% show instructions
        if any(vars.instructions.showE == thisTrial) || any(vars.instructions.showS ==thisTrial)
            
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            if any(vars.instructions.showS ==thisTrial)
                whichInstruction = find(vars.instructions.showS==thisTrial);
                DrawFormattedText(scr.win, uint8([vars.instructions.Start{whichInstruction}]), 'center', 'center', scr.TextColour, 60);
                [~, ~] = Screen('Flip', scr.win);
                
                while keys.KeyCode(keys.Space) == 0 % Wait for trigger
                    [~, ~, keys.KeyCode] = KbCheck;
                    WaitSecs(0.001);
                end
                
          else
                [~,whichInstruction] = min(abs(thisTrial-vars.instructions.showE));
                whichInstruction = mod(whichInstruction,3)+1;
                DrawFormattedText(scr.win, uint8([vars.instructions.Position{whichInstruction}]), 'center', 'center', scr.TextColour, 60); 
                [~, ~] = Screen('Flip', scr.win);
                WaitSecs(vars.task.movingT);
            end
            
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
            
            if keys.KeyCode(keys.Escape)==1 % if ESC, quit the experiment
                % Save, mark the run
                TcsAbortStimulation(vars.control.ser)
                TcsSetBaseLine(vars.control.ser,32)
                TcsCloseCom(vars.control.ser)
                return
            end
            
            new_line;
        end
        
       
        %% Trial starts: Configure temperatures and draw fixation point

        Tcold = vars.task.TcoldArray (vars.task.randTidx(thisTrial));
        Twarm = vars.task.TwarmArray (vars.task.randTidx(thisTrial));
                
        Tcold=single(round(Tcold,1)); %Round values so it interfaces better with stimulator
        Twarm=single(round(Twarm,1));
          
        % Draw Fixation
%         [~, ~] = Screen('Flip', scr.win);            % clear screen
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        scr = drawFixation(scr); % fixation point
        [~, ~] = Screen('Flip', scr.win);
        
        %% Jitter
        WaitSecs(vars.task.jitter(thisTrial));
          
        %% Stimulate
            vars.control.thisTrial =thisTrial;
%             while any(isnan(Response(thisTrial,find(vars.instructions.whichQuestion)))) 
                
               [vars.control.stimTime,~, ~, ~]  = stimulateVarDur(Results, scr,vars,keys,2,vars.stim.durationP,Tcold,Twarm); % Stimulate TGI
               %%Brief feedback to experimenter
               disp(['Trial #' num2str(thisTrial) ', Twarm = ' num2str(Twarm) ', Tcold = ' num2str(Tcold)])
               
               %% Get Response´
               
               switch vars.task.isVas (thisTrial)
                   case 0
                       for question_type_idx=1:2 % Only runs instructions 1 and 2
                           if vars.instructions.whichQuestion(question_type_idx)==1
                               vars.control.inputDevice = 2; %Setting keyboard
                               [Response(thisTrial,question_type_idx),~, vars] = getResponse(scr, vars,question_type_idx);
                           end
                       end
                   case 1
                       for question_type_idx=3:5 % Only runs instructions 1 and 2
                           if vars.instructions.whichQuestion(question_type_idx)==1
                               vars.control.inputDevice = 2; %1- mouse %2-keyboard
                               Response(thisTrial,3)= getVasRatings(keys, scr, vars,question_type_idx);
                           end
                       end
               end
               %% ITI
               stimulatePulse(Results,scr,vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
%             end
  

        %% Continue to next trial or time to stop? (max # trials reached)
        if (thisTrial == vars.task.NTrialsTotal)
            endOfExpt = 1;
        else
            % Advance one trial
            thisTrial = thisTrial + 1;
        end
        
    end % end trial

    
    ShowCursor;

%% Restore path
rmpath(genpath('code'));
cd(vars.dir.projdir)
sca;
ShowCursor;
Priority(0);
ListenChar(0);    
    
  
% catch ME% Error. Clean up...
%     
%     % Save, mark the run
%     vars.control.RunSuccessfull = 0;
%     vars.control.Error = 1;
%     experimentEnd(vars, scr, keys, Results);
%     rethrow(ME)
end