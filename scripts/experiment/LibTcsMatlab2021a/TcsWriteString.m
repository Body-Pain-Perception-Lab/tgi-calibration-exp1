% send a string to TCS
function TcsWriteString( ser, str )
% 
global tcsFirmwareVersion14orHigher %var to be set to true or false before calling this function

if tcsFirmwareVersion14orHigher
    
    %firmware >=14: no need to wait between each character send !
    %it speeds up communication between PC and TCS !
    write( ser, str, 'char' ); 
    flush( ser, 'output' ); %flush output characters
    
else
    
    %old firmware: ensure 1ms delay between each char and flushes output
    for i = 1:length( str )
        pause( 0.001 ); %1ms between each character send
        %disp( join( ['<',str(i),'>'], '' ) );
        write( ser, str(i), 'char' ); %send char
        flush( ser, 'output' ); %flush output character
    end %endfor
    
end

