function copy2VMPaux_TPL(subID)
% copy behavioural data from 3_VMP_NiiaTasks/data/subID  or 2_VMP_RestingState/data to 1_VMP_aux
%
%  Project Visceral mind project cohrot 1 / study summer 2020
%
% To include at the end of CWTwrapper and runRestingState
%
% Niia Nikolova
% 30 July 2020

subIDstring = sprintf('%04d', subID);
% dataDirectory = fullfile('..', '1_VMP_aux', ['sub_', subIDstring]); % From NiiaTasks

% First try saving to /aux/ drive. If that fails, save locally
%dataDirectory = strcat(filesep, filesep, 'hyades00.pet.auh-dk', filesep, 'aux', filesep, 'MINDLAB2019_Visceral-Mind', filesep, 'TPL', filesep, ['sub_', subIDstring]); % From NiiaTasks
dataDirectory =  ['\\hyades00.pet.auh.dk\aux\MINDLAB2019_Visceral-Mind\TPL\sub_' subIDstring];
%stimDirectory =  ['\\hyades00.pet.auh.dk\aux\MINDLAB2019_Visceral-Mind\TPL\sub_' subIDstring '\stimuli'];
%altDataDirectory = fullfile('..', 'TPL', ['sub_', subIDstring]);
if ~exist(dataDirectory, 'dir') 
    mkdir(dataDirectory)
end
    
% if ~exist(stimDirectory, 'dir') 
%     mkdir(stimDirectory)
% end
    
targetFolder = dataDirectory;
files2move = fullfile('.', 'data', ['sub_', subIDstring]);
files2movePath = fullfile(files2move, ['*', subIDstring,'*']);
copyfile(files2movePath, targetFolder)

%morefiles2move = fullfile('.', 'data', ['sub_', subIDstring], 'stimuli');
%morefiles2movePath = fullfile(morefiles2move, 'stimuli',['*', 'trial' ,'*']);
%copyfile(morefiles2move, morefiles2movePath)


end