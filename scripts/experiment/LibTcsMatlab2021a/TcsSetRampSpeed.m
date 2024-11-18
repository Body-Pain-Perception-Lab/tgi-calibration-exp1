% set stimulation ramp speed temperature in °C/s
% rampSpeed = array of five absolute temperature speed in °C/s
% min max = 0.1 to 300 °C/s
function TcsSetRampSpeed( ser, rampSpeed )

%threeshold 0.1 to 300°C/s
for i=1:5
    if rampSpeed(i) > 300 rampSpeed(i) = 300; end
    if rampSpeed(i) < 0.1 rampSpeed(i) = 0.1; end
end

%check if speeds are equal...
if ( rampSpeed(1) == rampSpeed(2) )...
    &( rampSpeed(1) == rampSpeed(3) )...
    &( rampSpeed(1) == rampSpeed(4) )...
    &( rampSpeed(1) == rampSpeed(5) )

    %yes: send all speeds in one command
    command = sprintf( 'V0%04d', rampSpeed(1)*10 );
    %disp( command );
    TcsWriteString( ser, command );
else        
    %no: send speeds in separate commands
    for i=1:5
        command = sprintf( 'V%d%04d', i, rampSpeed(i)*10 );
        %disp( join( ['<',command,'>'], '' ) );
        TcsWriteString( ser, command );
    end
end

