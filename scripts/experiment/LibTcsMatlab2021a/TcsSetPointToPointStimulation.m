% set "point to point" stimulation curve
% ser: handle of serial com with TCS
% zones: array of 5 '0' or '1' to choose zones to be set
% time: array of time in seconds
% temperature: array of temperature in °C
% time and temperature are row vectors with same length.
% first point must have time = 0 and temperature = neutral

function TcsSetPointToPointStimulation( ser, zones, time, temperature )  

%check parameters
erreur = [];
if size( time, 2 ) ~= size( temperature, 2 )
    erreur = "time and temperature arrays do not have the same length";
end 
if (size( temperature, 1 ) ~= 1) or (size( time, 1 ) ~= 1)
    erreur = "time and temperature must be raw vectors";
end
if size( time, 2 ) > 999
    erreur = "length of arrays must be < 1000";
end 
if time(1) ~= 0
    erreur = "time(0) must be equal to 0";
end 
if ~isempty(erreur)
    disp(["TcsSetPointToPointStimulation: error: ", erreur]);
    return
end

%round time to 10ms !
time = round(time*100)/100;

%compute time intervals between points
deg = temperature(2:end);
delta = time(2:end) - time(1:end-1); %time intervals in seconds

%intervals must be less or equal to 9.990s ( 9990ms )
%so this loop generates intermediate points if necessary
sup9990ms = true;
while sup9990ms
    sup9990ms = false;
    for i = 1:length( delta )
        if delta(i) > 9.99
            sup9990ms = true;
            if i == 1
              %add point at beginning
              delta = [ delta(1)/2, delta(1)/2, delta(2:end) ];
              deg = [ (temperature(1)+deg(1))/2, deg ];  
            else
                if i == length( sec )
                  %add point at the end
                  delta = [ delta(1:i-1), delta(i)/2, delta(i)/2 ];
                  deg = [ deg(1:i-1), (deg(i-1)+deg(i))/2, deg(i) ];  
                else
                  %add intermediate point
                  delta = [ delta(1:i-1), delta(i)/2, delta(i)/2, delta(i+1:end) ];
                  deg = [ deg(1:i-1), (deg(i-1)+deg(i))/2, deg(i:end) ];  
                end
            end
            break; %quit for loop
        end
    end
end

%send array of point (intervals,temperature) to TCS
command = sprintf( 'Uw%d%d%d%d%d%.3d', zones, length(delta) );
TcsWriteString( ser, command );
for i=1:length(delta)
    command = sprintf( '%.3d%.3d', round( delta(i)*100 ), round( deg(i)*10 ) );
    TcsWriteString( ser, command );
end
