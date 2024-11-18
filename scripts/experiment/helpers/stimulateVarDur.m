function [stimTime,stimOn, stimOff, tcsData] = stimulateVarDur(Results, scr, vars,keys,type,duration,varargin)

%Type: 0: cold, 1: warm, 2:TGI
%Question type: Array with ones or zeros stating which questions to ask. Refer to parameters' file.
%VARARGIN: If used 1-Tcold 2-Twarm
%% Set parameters
if length(varargin)<2 
    type=3;
%     warning('Cold or Warm specifications are missing. Stimulating with baseline temperature'); 
else
    Tcold = varargin{1};
    Twarm = varargin{2};
end

%TCS
TcsSetBaseLine(vars.control.ser,vars.task.Tbaseline); % skin temperature/baseline temperature
% TcsSetDurations(vars.control.ser,repmat(vars.stim.durationS,1,5)); % stimulation duration
TcsSetRampSpeed(vars.control.ser,repmat(vars.stim.speed_ramp,1,5)); % rate of temperature change to target
TcsSetReturnSpeed(vars.control.ser,repmat(vars.stim.return_ramp,1,5)); % rate of temperature change to baseline

% randomize stimulation bars

switch type
    case 0 % Cold. Select one within the 4 possibilities.
        possibilities = {[1 1 0 0 0],...
            [0 1 1 0 0],...
            [0 0 1 1 0],...
            [0 0 0 1 1]};
        possibilities_idx = randi(4);
        tcs_temperatures = single(possibilities{possibilities_idx});
        tcs_temperatures(tcs_temperatures==0)= vars.task.Tbaseline;
        tcs_temperatures(tcs_temperatures==1)= Tcold;
        
    case 1 % Warm. Selct one within the 3 possibilities
        possibilities = {[1 1 1 0 0],...
            [0 1 1 1 0],...
            [0 0 1 1 1]};
        possibilities_idx = randi(3);
        tcs_temperatures = possibilities{possibilities_idx}*Twarm;
        tcs_temperatures(tcs_temperatures==0)= vars.task.Tbaseline;
        
    case 2 % TGI. Selct one within the 3 possibilities
        possibilities = [1 0 1 0 1];
        tcs_temperatures = possibilities*Twarm;
        tcs_temperatures(tcs_temperatures==0) = Tcold;
        
    case 3 %Baseline
        tcs_temperatures = single(ones(1,5)*vars.task.Tbaseline);
end


TcsSetTemperatures(vars.control.ser,tcs_temperatures); % 5 stimulation temperatures

timepoint = 0;

%% STIMULATE
stimOn = GetSecs;

TcsFollowMode(vars.control.ser)
%% Get and save temperature data during stimulation
stimTime = tic; % timer for recording

% loop until RespT is reached
end_stim = 0;
endCounter_started =0;
end_timer = Inf;

while end_stim==0
% while toc(stimTime) <= duration % get tcs data for a predefined amount of time
    timepoint = timepoint + 1; % update counter
    time_sampled = toc(vars.control.startTask);   % timing with respect to when the experiment started
%     time_array (timepoint) = toc(stimTime);
    temperatures = TcsGetTemperatures(vars.control.ser); % get temperatures from USB port
    %     disp(num2str(temperatures)) % show current temperatures
    tcsData(timepoint,1) = vars.control.thisTrial; % trial number
    tcsData(timepoint,2) = time_sampled; % stimulation timing
    tcsData(timepoint,3:7) = temperatures; % temperatures of 5 zones
    
    % KbCheck for Esc key
    if keys.KeyCode(keys.Escape)== 1
        % Save, mark the run
        vars.RunSuccessfull = 0;
        vars.Aborted = 1;
        experimentEnd(keys, Results, scr, vars);
        return
    end
    
    [~, ~, keys.KeyCode] = KbCheck;
    WaitSecs(0.001);
    
    if all(abs(temperatures-tcs_temperatures)<=vars.stim.Ttol*ones(size(tcs_temperatures))) && endCounter_started==0 %start counting
        end_timer = toc(stimTime);
        endCounter_started =1;
        t=timepoint;
    end
    
    if (toc(stimTime)-end_timer)>duration
        end_stim=1;
        %quit "follow mode"
        TcsAbortStimulation(vars.control.ser);
    end
end

stimOff = GetSecs;
% warning('on')
% if any((abs(tcsData(end,3:7)-tcs_temperatures) > vars.task.Ttol*ones(size(tcs_temperatures)))) && ~isequal(type,3)
%     warning('Target temperature not reached')
% end

%%
% clf
%     for ii=1:5
%         subplot(3,2,ii)
%         plot((tcsData(:,2)-tcsData(1,2)),tcsData(:,2+ii))
%         hold on
%         xline(tcsData(t,2)-tcsData(1,2))
%         xline(tcsData(end,2)-tcsData(1,2))
%         title(['Termode ' num2str(ii)])
%     end
% tcsData(end,2)-tcsData(t,2)
end