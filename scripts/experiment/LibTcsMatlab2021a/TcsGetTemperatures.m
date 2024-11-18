% get current temperatures of zone 1 to 5 in °C
% returns an array of five temperatures
% if error returns an empty array
function [ temperatures ] = TcsGetTemperatures( ser )

flush( ser, 'input' );
TcsWriteString( ser, 'E' );
%get neutral + t1 to t5 
data = read( ser, 24, 'char' ); %'/r' + 'xxx?xxx?xxx?xxx?xxx?xxx' with '?' = sign '+' ou '-'
%disp( data );
if size( data, 2 ) > 23
    neutral = str2num( data(2:4) );
    temperatures( 1 ) = str2num( data(5:8) ) /10;
    temperatures( 2 ) = str2num( data(9:12) ) /10;
    temperatures( 3 ) = str2num( data(13:16) ) /10;
    temperatures( 4 ) = str2num( data(17:20) ) /10;
    temperatures( 5 ) = str2num( data(21:24) ) /10;
else
    temperatures = []; 
end