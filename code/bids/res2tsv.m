function df = res2tsv(path, project, sub_n, ses_n, task, datatype)
% RES2TSV generate tsv files based on matalab source data containing
% fast multi-threshold results
    subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
    session = ['ses-' num2str(ses_n,'%02.f')]; % Define session
    task_name = 'fastTrl';

    %filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'session '_' 'task-' task '_' datatype]); % how it should be
    filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'ses-session' num2str(ses_n) '_' 'task-' task '_' datatype '.mat']); % temporary fix
    filename = fullfile(path, project, subject, session, datatype, [subject '_' session '_' 'task-' task_name '_' datatype '.tsv']); % how it should be
    
    % Check source data and generate tsv
    if isfile(filename_source)
        load(filename_source)
        fast = Results.myfast;
            
        if sub_n == 7 && ses_n == 1 % exception for participant 7, session 1
            warning('Problem in Results.estimate for sub-0007.  Assigning the second last values.');
            fast.params.est = Results.estimate{end-1}; % exception for participant 7 
        else
            fast.params.est = Results.estimate{end};
        end

        % data
        trials = 1:100;
        sub = repmat(sub_n,length(trials),1);
        ses = repmat(ses_n,length(trials),1);
        task = repmat('fast',length(trials),1); % 'fast' instead of the variable task_name
        datatype = repmat(datatype,length(trials),1);
        trial_n = transpose(1:length(trials));

        cold_t = Results.targetTcold;    % cold temperature for each stimulus/trial
        warm_t = Results.targetTwarm;    % warm temperature for each stimulus/trial
        burn_yn = Results.Response(:,1); % participant's response: 0 = not burning, 1 = burning
        temp_cw = Results.Response(:,2); % participant's response: 0 = cold, 1 = warm

        % create table
        df = table(sub, ses, task, datatype, trial_n, cold_t, warm_t, burn_yn, temp_cw);
        % write tsv file
        writetable(df,filename,'FileType','text','Delimiter','\t');
  
    else
        fprintf('Trial-by-trial source data does not exist for %s %s\n', subject, session)
        df = [];
    end 
end