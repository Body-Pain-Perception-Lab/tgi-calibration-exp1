% set TCS in "quiet mode"
% otherwise TCS sends regularly temperature data
% ( @1Hz if no stimulation, @100Hz during stimulation )
function TcsQuietMode( ser )

TcsWriteString( ser, 'F' );

