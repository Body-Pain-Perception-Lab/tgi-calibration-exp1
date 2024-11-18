% set stimulation durations in seconds
% durations = array of five duration in s
% min max = 0.1 to 60.0 °C
function TcsSetDurations( ser, durations )

%threeshold 0 to 60 °C
for i=1:5
    if durations(i) > 99.999 durations(i) = 99.999; end
    if durations(i) < 0.001 durations(i) = 0.001; end
end

%check if speeds are equal...
if ( durations(1) == durations(2) )...
    &( durations(1) == durations(3) )...help pringf
    &( durations(1) == durations(4) )...
    &( durations(1) == durations(5) )

    %yes: send all speeds in one command
    command = sprintf( 'D0%05d', durations(1)*1000 );
    %disp( command );
    TcsWriteString( ser, command );
else        
    %no: send speeds in separate commands
    for i=1:5
        command = sprintf( 'D%d%05d', i, durations(i)*1000 );
        %disp( join( ['<',command,'>'], '' ) );
        TcsWriteString( ser, command );
    end
end

