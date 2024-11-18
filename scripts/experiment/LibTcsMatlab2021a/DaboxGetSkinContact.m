%function contact = DaboxGetSkinContact( ser );
%   get skin contact state
%   return 1 if skin in contact, otherwise return 0
% parameter:
%   ser: DABOX serial handle
function contact = DaboxGetSkinContact( ser );

flush( ser, 'input' ); %flush input characters
write( ser, 'P', 'char'); %send command
flush( ser, 'output' ); %flush output characters
contactStr = read( ser, 1, 'char' ); %read '0' or '1'
contact = num2str( contactStr );
