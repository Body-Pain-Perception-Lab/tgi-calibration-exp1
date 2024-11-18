% Abort current stimulation or exit 'follow mode'

function TcsAbortStimulation( ser )

TcsWriteString( ser, 'A' );

