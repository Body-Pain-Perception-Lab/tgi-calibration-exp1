% get buttons state: 0=released, 1=pressed
function buttonsState = TcsGetButtons( ser )

%ask buttons state
flush( ser, 'input' );
TcsWriteString( ser, 'K' );

%read buttons state
data = read( ser, 3, 'char' ); % '/r' + 'xx'
if size( data, 2 ) > 2
    buttonsState(1) = str2num( data(2) );
    buttonsState(2) = str2num( data(3) );
else
    buttonsState = [];
end