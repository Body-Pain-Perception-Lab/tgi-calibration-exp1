% set stimulation temperature in °C
% temperatures = array of fivetemperatures in °C
% min max = 0.0 to 60.0 °C
function TcsSetTemperatures( ser, temperatures )

%threeshold 0 to 60 °C
for i=1:5
    if temperatures(i) > 60 temperatures(i) = 300; end
    if temperatures(i) < 0.1 temperatures(i) = 0.1; end
end

%check if speeds are equal...
if ( temperatures(1) == temperatures(2) )...
    &( temperatures(1) == temperatures(3) )...help pringf
    &( temperatures(1) == temperatures(4) )...
    &( temperatures(1) == temperatures(5) )

    %yes: send all speeds in one command
    command = sprintf( 'C0%03d', temperatures(1)*10 );
    %disp( command );
    TcsWriteString( ser, command );
else        
    %no: send speeds in separate commands
    for i=1:5
        command = sprintf( 'C%d%03d', i, temperatures(i)*10 );
        %disp( join( ['<',command,'>'], '' ) );
        TcsWriteString( ser, command );
    end
end

