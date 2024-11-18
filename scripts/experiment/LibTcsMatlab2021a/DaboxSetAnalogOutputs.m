% function DaboxSetAnalogOutputs( ser, temp )
%   set 6 analog outputs of DABOX
% parameters:
%   ser: DABOX serial handle
%   temp: array of 6 temperatures in °C ( -3 to +63 °C )
% voltage conversion formula:
%   output voltage = ( temperature + 3 ) / 20
%   temperature = output voltage * 20 - 3
%   output range = 0 to 3.3 Volt ( = -3 to +63 °C )

function DaboxSetAnalogOutputs( ser, temp )
%build command
command = 'A'; 
for i=1:6
    %threeshold -3 to 63 °C
    if temp(i) > 63 temp(i) = 63; end
    if temp(i) < -3 temp(i) = -3; end
    %send temp with sign
    if temp(i) < 0
        command = [ command, sprintf( '-%03d', round(-temp(i)*10) ) ];
    else
        command = [ command, sprintf( '+%03d', round(temp(i)*10) ) ];
    end
end
%send command
disp ( command );
write( ser, command, 'char' ); 
flush( ser, 'output' ); %flush output characters
