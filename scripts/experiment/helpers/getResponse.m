function [Resp, RT, vars] = getResponse(scr, vars,question_type_idx)
%%get response for TGI Multi

Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
DrawFormattedText(scr.win, uint8([vars.instructions.Question{question_type_idx}]), 'center', 'center', scr.TextColour);
[~, answerTimeOn] = Screen('Flip', scr.win);

% get response and update button press results
switch vars.control.inputDevice
    case 1 % mouse
        [~,~,buttons] = GetMouse;
        [keys] = keyConfig();
        
        while (~any(buttons)) && ((GetSecs - answerTimeOn) <= vars.task.RespT) && (keys.KeyCode(keys.Escape)==0) % wait for press & response time
            [~,~,buttons] = GetMouse; % L [1 0 0], R [0 0 1]
            [~, ~, keys.KeyCode] = KbCheck; %Check for Esc
        end
        
        if buttons == [1 0 0] %#ok<BDSCA> % LEFT button press
            Resp = 1; %Yes
            RT = toc(vars.control.stimTime);
%             vars.control.ValidTrial(1) = 1;
        elseif buttons == [0 0 1]
            Resp = 0;
            RT = toc(vars.control.stimTime);
%             vars.control.ValidTrial(1) = 1;
        elseif keys.KeyCode(keys.Escape)==1
            vars.control.Aborted = 1;
            vars.control.RunSuccessful = 0;
            return
        else
            Resp = NaN;
            RT = NaN;
%             vars.control.ValidTrial(1) = 0;
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, uint8(['Please press a valid key...']), 'center', 'center', scr.TextColour);
        end
        vars.control.EndRT = GetSecs;
        
    case 2  % Keyboard response
        [keys] = keyConfig();
        
        while (~any(keys.KeyCode)) && ((GetSecs - answerTimeOn) <=  vars.task.RespT)  % wait for press & response time
            [~, ~, keys.KeyCode] = KbCheck;
        end
        
        switch vars.instructions.whichKey{question_type_idx}%Which buttons to use? Left Right or Up Down?
            case 'LR'
                key_1 = keys.Left;
                key_0 = keys.Right;
                feedbackXPosOffset = 250;
                feedbackYPosOffset = 0;
            case 'UD'
                key_1 = keys.Up;
                key_0 = keys.Down;
                feedbackXPosOffset = 0;
                feedbackYPosOffset = 250;
        end
         
        
        % KbCheck for response
        if keys.KeyCode(key_1)==1         % Yes
            Resp = 1;
            RT = toc(vars.control.stimTime);
%             vars.control.ValidTrial(1) = 1;
        elseif keys.KeyCode(key_0)==1    % No
            Resp = 0;
            RT = toc(vars.control.stimTime);
            vars.control.ValidTrial(1) = 1;
        elseif keys.KeyCode(keys.Escape)==1
            vars.control.Aborted = 1;
            vars.control.RunSuccessful = 0;
            return
        else
            Resp = NaN;
            RT = NaN;
%             vars.control.ValidTrial(1) = 0;
        end
        
end


%% Brief feedback
%Screen
feedbackColour = [0 0 0];

Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
if Resp == 1
    DrawFormattedText(scr.win, uint8([vars.instructions.Question{question_type_idx}]), 'center', 'center', scr.TextColour); %Instruction does not disappear 
    feedbackXPos = ((scr.winRect(3)/2)-feedbackXPosOffset);
    feedbackYPos = ((scr.winRect(4)/2)-feedbackYPosOffset);
    feedbackString = 'O';
elseif Resp == 0
    DrawFormattedText(scr.win, uint8([vars.instructions.Question{question_type_idx}]), 'center', 'center', scr.TextColour);%Instruction does not disappear 
    feedbackXPos = ((scr.winRect(3)/2)+feedbackXPosOffset);
    feedbackYPos = ((scr.winRect(4)/2)+feedbackYPosOffset);
    feedbackString = 'O';
else
    feedbackString = 'Please press a valid key.';
    feedbackXPos = ((scr.winRect(3)/2)-150);
    feedbackYPos = ((scr.winRect(4)/2));
end
DrawFormattedText(scr.win, feedbackString, feedbackXPos, feedbackYPos, feedbackColour); 
[~, ~] = Screen('Flip', scr.win);
WaitSecs(vars.task.feedbackBPtime);

% Draw Fixation
[~, ~] = Screen('Flip', scr.win);            % clear screen
Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
scr = drawFixation(scr); % fixation point
[~, ~] = Screen('Flip', scr.win);

%% Brief feedback to experimenter
if Resp == 1
    disp(vars.instructions.Feedback{2-mod(question_type_idx,2),1}) % 
elseif Resp == 0
    disp(vars.instructions.Feedback{2-mod(question_type_idx,2),2})
else
    disp('No response recorded. Repeating trial')
end
end