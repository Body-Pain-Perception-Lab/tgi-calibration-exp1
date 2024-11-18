% get probe ID au format texte sans espaces
function probeId = TcsGetProbeId( ser );

flush( ser, 'input' );
TcsWriteString( ser, "H");
aide = read( ser, 100, 'char' ); %recup "aide" au format texte
flush( ser, 'input' );
iID = strfind( aide, "ID"); %recup position de "ID"
probeId = aide( iID+3:iID+26 ); %recup rom ID
probeId = erase( probeId, " " );%suppression des espaces
warning('off','all');
reste = read( ser, 10000, 'char' ); %vide le reste du buffer...
warning('on','all')