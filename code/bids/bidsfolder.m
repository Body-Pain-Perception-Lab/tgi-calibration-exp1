function bidsfolder(path, project, sub_n, ses_n, datatype)
% BIDSfolder check whether BIDS folders already exist, otherwise creates them

    subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
    session = ['ses-' num2str(ses_n,'%02.f')]; % Define session
    bids_subject_folder = fullfile(path,project,subject); % subject folder
    bids_session_folder = fullfile(bids_subject_folder, session); % session folder
    bids_datatype_folder = fullfile(bids_session_folder, datatype); % datatype folder 
      
    % Check folders
    if ~exist(bids_subject_folder)
        mkdir(bids_subject_folder)
    end

    if ~exist(bids_session_folder)
         mkdir(bids_session_folder)
    end
            
    if ~exist(bids_datatype_folder)
         mkdir(bids_datatype_folder)
    end  
end