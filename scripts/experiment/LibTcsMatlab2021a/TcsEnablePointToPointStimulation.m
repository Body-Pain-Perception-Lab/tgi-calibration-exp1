% enable/disable "point to point" stimulation 
% ser: handle of serial com with TCS 
% enableDisable: array of five '0'(disable) or '1'(enable)
function TcsEnablePointToPointStimulation( ser,  enableDisable )  
command = sprintf( 'Ue%d%d%d%d%d', enableDisable );
TcsWriteString( ser, command );

