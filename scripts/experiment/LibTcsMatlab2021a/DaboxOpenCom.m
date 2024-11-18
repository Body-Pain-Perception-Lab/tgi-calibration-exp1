% open serial com with DABOX
% if found DABOX then returns matlab serial port object
% else returns empty
function DABOX = DaboxOpenCom( noCom )

%close DABOX com if allready opened !
seriallist = instrfind( 'Type', 'serial' );
for i = 1:length( seriallist )
   if strcmp( get( seriallist(i), 'UserData' ), 'DABOX' ) then
        fclose( seriallist(i) );
   end
end

%try to open com
disp('Initializing DABOX device');
DABOX = serialport( [ 'COM', int2str(noCom) ], 115200, 'Timeout', 1 );
DABOX.UserData = 'DABOX';
