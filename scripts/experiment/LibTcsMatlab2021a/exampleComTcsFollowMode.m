% TCS "follow mode" example:
% Probe goes to the setpoint temperature and remains there as long as the setpoint does not change.
% set baseline temperature, speed and temperature setpoint
% get into "follow mode"
% update temperature setpoint and get temperatures in a loop
% quit "follow mode" ("abort")
% ( time in s, temperatures in °C, speed in °C/s )

%clean up workspace ...
clear all

%set this global variable to:
% true if tcs firmware version 14 or higher
% false if tcs firmware lower than 14
global tcsFirmwareVersion14orHigher;
tcsFirmwareVersion14orHigher = true;

%open com, parameter is com number
tcs = TcsOpenCom( 'COM14' );

%display probe ID
disp( ['probe ID:' TcsGetProbeId( tcs ) ] );

%set TCS in "quiet mode"
% otherwise TCS sends regularly temperature data
% ( @1Hz if no stimulation, @100Hz during stimulation )
% and that can corrupt dialog between PC and TCS
TcsQuietMode( tcs );

tcs_temperature = 15;
tcs_baseline = 30;

%set parameters
TcsSetBaseLine( tcs, tcs_baseline ); %set baseline 31°C
TcsSetRampSpeed( tcs, [ 5 6 7 8 9 ] ); %set ramp speed for 5 zones
TcsSetTemperatures( tcs, repmat(tcs_temperature, 1, 5) ); %temperature setpoint

%get into "follow mode":
% probe goes to setpoint @ramp speed
TcsFollowMode( tcs );

%loop to record stimulation temperatures
recordDuration = 16;
rampDuration = 8;
tic; %set start time
currentTime = toc; %get current time
prevCurrentTime = currentTime; %init previous current time
cpt = 0;
while currentTime < recordDuration
    
    %get and record current temperatures and time
    cpt = cpt + 1;
    currentTime = toc; %get current time
    currentTemperatures = TcsGetTemperatures( tcs ); %get current temperature
    disp( currentTemperatures ); %disp current temperature
    t( cpt, 1:5 ) = currentTemperatures; %record temperatures in t
    x( cpt, 1 ) = currentTime; %reccord current time
    
    %check if button pressed
    buttonsState = TcsGetButtons( tcs );
    if buttonsState(1) == 1 disp ('button 1 pressed'); end
    if buttonsState(2) == 1 disp ('button 2 pressed'); end    
   
    %change temperature setpoint @3s 
    if ( currentTime >= rampDuration ) && ( prevCurrentTime < rampDuration )
        TcsSetTemperatures( tcs, [ 35 35 35 35 35  ] ); %temperature setpoint
    end
    prevCurrentTime = currentTime;
        
end    

%quit "follow mode"
TcsAbortStimulation( tcs );

%display 5x temp curves
plot( x, t(:,1) ); hold on;
plot( x, t(:,2) );
plot( x, t(:,3) );
plot( x, t(:,4) );
plot( x, t(:,5) );
grid on; zoom on;
hold off;

%close com
TcsCloseCom( tcs );
