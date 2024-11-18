% Set TCS in "follow mode":
% Probe goes to the setpoint temperature and remains there as long as the setpoint does not change.

function TcsFollowMode( ser )

TcsWriteString( ser, 'Od' );

