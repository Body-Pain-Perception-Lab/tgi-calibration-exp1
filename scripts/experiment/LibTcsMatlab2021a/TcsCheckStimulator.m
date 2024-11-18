function ser = TcsCheckStimulator(vars)

%set this global variable to:
% true if tcs firmware version 14 or higher
% false if tcs firmware lower than 14
global tcsFirmwareVersion14orHigher;
tcsFirmwareVersion14orHigher = true;

%% check whether connection with the stimulator and battery level
% define and check USB port
if ~vars.control.stimFlag 
    disp('Debugging without stimulator')
else
    try
        ports = serialportlist; % identify port TCS stimulator connected to
        if (ports == "")
            sprintf('No TCS stimulator detected. Check connection')
        else
%              ser = TcsOpenCom(ports(1)); %open this port
           ser = TcsOpenCom(ports(5)); %open this port
        end
    catch
        warning('The USB port is not defined correctly. Please change vars.ser')
        return
    end
    % test port and check battery 
    [~, pct] = TcsGetBattery(ser);
    if isempty(pct)
        warning('Check whether stimulator is turned on and then restart wrapper or launcher')
        return
    else
        vars.battery = pct;
        disp(['Battery: ' num2str(pct) ' %']);
    end
    try
        TcsQuietMode(ser) % set quiet mode; this is necessary to read temperature data from USB port
    catch
        warning('Quiet mode not activated, may have issues with TcsGetTemperatures.m')
    end
    
    %display probe ID
    disp( ['probe ID:' TcsGetProbeId( ser ) ] );
end

