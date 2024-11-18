function vars = checkParticipantFiles(vars)
check_once = 0;
% Check if folder already exists in data dir
dataDirectory = fullfile('.', 'data', ['sub_',vars.subIDstring]);
if exist(dataDirectory, 'dir') && (vars.subNo ~= 9999)
    % Check which (if any) tasks the participant has already completed
    expectedDataFiles = {['qstThr_v1-1_',vars.subIDstring]; ['psiThr_v1-1_',vars.subIDstring]; ['TPL_v1-1_',vars.subIDstring]};
    
    for taskFiles = 1%expectedDataFiles{taskN}
        
        foundFiles = dir(strcat(dataDirectory, filesep, expectedDataFiles{vars.taskN}, '*.mat'));
        
        if ~check_once
            if size(foundFiles,1) ~= 0
                if isempty(foundFiles(1).name)
                    % No file exists for this task
                else
                    % File already exists in Outputdir
                    if vars.subNo ~= 9999
                        disp(['The file ' foundFiles.name ' already exists'])
                        subj_confirmed = input('Do you confirm the participant number. yes-1 no-0?      ');
%                         if subj_confirmed
%                             vars.startTrialN = input('Define the trial number to restart from?   ');
%                             check_once = 1;
%                         else
%                             return
%                         end
                    end
                end
            end
        end
    end
end