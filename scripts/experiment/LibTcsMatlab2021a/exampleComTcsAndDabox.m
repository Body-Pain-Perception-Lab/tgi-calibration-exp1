%TCS and DABOX example:
% set stimulation
% start stimulation
% get temperatures and update DABOX outputs during stimulation
% display stimulation
% time in s, temperatures in °C, speed in °C/s

%clean up workspace ...
clear all

%set this global variable to:
% true if tcs firmware version 14 or higher
% false if tcs firmware lower than 14
global tcsFirmwareVersion14orHigher;
tcsFirmwareVersion14orHigher = true;

%open com with TCS and DABOX, parameter is com number
tcs = TcsOpenCom( 4 );
dabox = DaboxOpenCom( 10 );

%display probe ID
disp( ['probe ID:' TcsGetProbeId( tcs ) ] );

%set TCS in "quiet mode"
% otherwise TCS sends regularly temperature data
% ( @1Hz if no stimulation, @100Hz during stimulation )
% and that can corrupt dialog between PC and TCS
TcsQuietMode( tcs );

%set parameters
TcsSetBaseLine( tcs, 31.0 ); %set baseline 31°C
TcsSetDurations( tcs, [ 1 2 3 4 5 ] ); %set durations for 5 zones
TcsSetRampSpeed( tcs, [ 5 6 7 8 9 ] ); %set ramp speed for 5 zones
TcsSetReturnSpeed( tcs, [ 9 8 7 6 5] ); %set return speed for 5 zones
TcsSetTemperatures( tcs, [ 15 20 25 35 40 ] ); %set ramp speed for 5 zones

%send stimulation
TcsStimulate( tcs );

%loop to record stimulation temperatures
recordDuration = 6;
tic; %set start time
currentTime = toc; %get current time
cpt = 0;
while currentTime < recordDuration
    %get current temperatures of 5 zones
    currentTemperatures = TcsGetTemperatures( tcs );
    %update DABOX 6 analog outputs: mean temperature, temperatures of 5 zones
    DaboxSetAnalogOutputs( dabox, [ mean( currentTemperatures ), currentTemperatures ] );
    %display current temperatures
    disp( currentTemperatures ); %disp current temp
    %record current temperatures and time
    cpt = cpt + 1;
    t( cpt, 1:5 ) = currentTemperatures; %record temperatures in t
    currentTime = toc; %get current time
    x( cpt, 1 ) = currentTime;
    %check if button pressed
    buttonsState = tcsGetButtons( tcs );
    if buttonsState(1) == 1 disp ('button 1 pressed'); end
    if buttonsState(2) == 1 disp ('button 2 pressed'); end    
end    
    
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
DaboxCloseCom( dabox);
