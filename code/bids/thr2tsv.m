function df = thr2tsv(path, project, sub_n, ses_n, task, datatype)
% THR2TSV generate tsv files based on matalab source data containing
% fast multi-threshold results
    subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
    session = ['ses-' num2str(ses_n,'%02.f')]; % Define session
    task_name = 'fastEst';

    %filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'session '_' 'task-' task '_' datatype]); % how it should be
    filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'ses-session' num2str(ses_n) '_' 'task-' task '_' datatype '.mat']); % temporary fix
    filename = fullfile(path, project, subject, session, datatype, [subject '_' session '_' 'task-' task_name '_' datatype '.tsv']); % how it should be
    
    % Check source data and generate tsv
    if isfile(filename_source)
        load(filename_source)
        fast = Results.myfast;
            
        % Define parameter estimates variable
        if sub_n == 7 && ses_n == 1 % exception for participant 7, session 1
            warning('Problem in Results.estimate for sub-0007.  Assigning the second last values.');
            fast.params.est = Results.estimate{end-1}; % exception for participant 7 
        else
            fast.params.est = Results.estimate{end};
        end
    
        % Extract parameter values (if they exist)
        if ~isempty(fast.params.est)
            % data
            temp_cold = transpose(0:0.1:30); % cold temperatures
            n = length(temp_cold);
            sub = repmat(sub_n,n*3,1);
            ses = repmat(ses_n,n*3,1);
            task = repmat(task_name,n*3,1);
            datatype = repmat(datatype,n*3,1);
            trial_n = repmat(transpose(1:n),3,1);
            threshold = [repmat(25,n,1); repmat(50,n,1); repmat(75,n,1)];
            temp_warm = [transpose(squeeze(fastCalcYs(fast,temp_cold,0.25,'margMean'))); ...    % warm temperature, 25% burning
                        transpose(squeeze(fastCalcYs(fast,temp_cold,0.5,'margMean'))); ...      % warm temperature, 50% burning
                        transpose(squeeze(fastCalcYs(fast,temp_cold,0.75,'margMean')))];        % warm temperature, 75% burning
            
            temp_cold = repmat(transpose(0:0.1:30),3,1); % repeat cold temperatures 3 times (25,50,75)
            % create table
            df = table(sub, ses, task, datatype, trial_n, threshold, temp_cold, temp_warm);
            % write tsv file
            writetable(df,filename,'FileType','text','Delimiter','\t');
        else
            fprintf('No "est" values are found for %s %s\n', subject, session)
            df = [];
        end
  
    else
        fprintf('Fast multithreshold source data does not exist for %s %s\n', subject, session)
        df = [];
    end 
end