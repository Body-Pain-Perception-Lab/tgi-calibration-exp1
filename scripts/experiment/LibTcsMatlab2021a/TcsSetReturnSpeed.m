% set stimulation return speed temperature in °C/s
% returnSpeed = array of five absolute temperature speed in °C/s
% min max = 0.1 to 300 °C/s
function TcsSetReturnSpeed( ser, returnSpeed )

%threeshold 0.1 to 300°C/s
for i=1:5
    if returnSpeed(i) > 300 returnSpeed(i) = 300; end
    if returnSpeed(i) < 0.1 returnSpeed(i) = 0.1; end
end

%check if speeds are equal...
if ( returnSpeed(1) == returnSpeed(2) )...
    &( returnSpeed(1) == returnSpeed(3) )...help pringf
    &( returnSpeed(1) == returnSpeed(4) )...
    &( returnSpeed(1) == returnSpeed(5) )

    %yes: send all speeds in one command
    command = sprintf( 'R0%04d', returnSpeed(1)*10 );
    %disp( command );
    TcsWriteString( ser, command );
else        
    %no: send speeds in separate commands
    for i=1:5
        command = sprintf( 'R%d%04d', i, returnSpeed(i)*10 );
        %disp( join( ['<',command,'>'], '' ) );
        TcsWriteString( ser, command );
    end
end

