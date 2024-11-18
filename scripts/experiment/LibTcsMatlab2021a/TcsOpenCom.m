% open serial com with TCS
% if found TCS then returns matlab serial port object
% else returns empty
function TCS = TcsOpenCom( noCom )

%close TCS com if allready opened !
seriallist = instrfind( 'Type', 'serial' );
for i = 1:length( seriallist )
   if strcmp( get( seriallist(i), 'UserData' ), 'TCS' )
        fclose( seriallist(i) );
   end
end

%try to open com
disp('Initializing TCS device');
if ispc
    TCS = serialport( noCom, 115200, 'Timeout', 1 ); % win
elseif ismac
    TCS = serialport( [ '/dev/tty.usbmodem', int2str(noCom) ], 115200, 'Timeout', 1 ); % mac
end
TCS.UserData = 'TCS';
