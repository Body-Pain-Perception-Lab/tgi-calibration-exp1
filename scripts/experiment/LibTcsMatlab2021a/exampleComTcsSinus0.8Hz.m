%TCS example: 5 periods of sinus @0.8Hz
%uses "point to point" stimulation set-up
% set stimulation
% start stimulation
% get temperatures during stimulation
% display stimulation
% time in s, temperatures in °C, speed in °C/s

%clean up workspace ...
clear all

%set this global variable to:
% true if tcs firmware version 14 or higher
% false if tcs firmware lower than 14
global tcsFirmwareVersion14orHigher;
tcsFirmwareVersion14orHigher = true;

%open com, parameter is com number
tcs = TcsOpenCom( 4 );

%display probe ID
disp( ['probe ID:' TcsGetProbeId( tcs ) ] );

%set TCS in "quiet mode"
% otherwise TCS sends regularly temperature data
% ( @1Hz if no stimulation, @100Hz during stimulation )
% and that can corrupt dialog between PC and TCS
TcsQuietMode( tcs );

%sinus parameters
sinusNeutral = 30;
sinusAmplitude = 10;
sinusFreq = 0.8;
sinusPeriod = 1/sinusFreq;
sinusNbrPeriod = 5;
sinusDuration = sinusNbrPeriod*sinusPeriod;
%sinusNbrSegmentsPerPeriod = 125; %10ms resolution
sinusNbrSegmentsPerPeriod = 25; %50ms resolution
%sinusNbrSegmentsPerPeriod = 10; %125ms resolution

%compute sinus time/temperature array
time = linspace( 0, sinusDuration, sinusNbrPeriod*sinusNbrSegmentsPerPeriod + 1 );
temperature = sinusNeutral + sin( time*2*pi/sinusPeriod )*sinusAmplitude;

%affiche sinus
plot(time,temperature,'r-*'); hold on;
%pause;

%set parameters
TcsSetBaseLine( tcs, sinusNeutral ); %set baseline
TcsEnablePointToPointStimulation( tcs, [ 1 1 1 1 1 ] );
TcsSetPointToPointStimulation( tcs, [ 1 1 1 1 1 ], time, temperature )

%enable all 5 zones
TcsEnableZones( tcs, [ 1 1 1 1 1 ] );

%send stimulation
TcsStimulate( tcs );

%loop to record stimulation temperatures
recordDuration = sinusDuration + 1;
tic; %set start time
currentTime = toc; %get current time
cpt = 0;
while currentTime < recordDuration
    %get and record current temperatures and time
    cpt = cpt + 1;
    currentTemperatures = TcsGetTemperatures( tcs );
    disp( currentTemperatures ); %disp current temp
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
