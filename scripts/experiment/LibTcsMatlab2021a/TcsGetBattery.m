% get battery voltage (v) and charge (%)
function [ volt, pct ] = TcsGetBattery( ser );

%ask battery info
flush( ser, 'input' );
TcsWriteString( ser, 'B' );

%get volt and pct 
data = read( ser, 14, 'char' ); % '/r' + 'xx.xxxxv xxx%'
if size( data, 2 ) > 13
    volt = str2num( data(2:8) );
    pct = str2num( data(12:13) );
else
    volt = [];
    pct = [];
end