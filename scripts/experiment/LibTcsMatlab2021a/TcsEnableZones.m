% enable/disable zones
% ser: handle of serial com with TCS 
% enableDisable: array of five '0'(disable) or '1'(enable)
function TcsEnableZones( ser,  enableDisable )  
command = sprintf( 'S%d%d%d%d%d', enableDisable );
TcsWriteString( ser, command );

