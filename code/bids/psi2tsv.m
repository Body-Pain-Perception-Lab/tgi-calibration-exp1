function df = psi2tsv(path, project, sub_n, ses_n, task, datatype)
% PSI2TSV generate tsv files based on matalab source data containing
% psi threshold results
    subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
    session = ['ses-' num2str(ses_n,'%02.f')]; % Define session
    task_name = 'psi';
    plot = false;
    
    % Define filenames
    filename_cold = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'ses-session' num2str(ses_n) '_' 'task-' task 'cold_' datatype '.mat']); % temporary fix
    filename_warm = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'ses-session' num2str(ses_n) '_' 'task-' task 'warm_' datatype '.mat']); % temporary fix
    filename = fullfile(path, project, subject, session, datatype, [subject '_' session '_' 'task-' task_name '_' datatype '.tsv']); % how it should be
    
    % Check source data and generate tsv
    % first for cold
    if isfile(filename_cold) && isfile(filename_warm)
        load(filename_cold)
        
        %%%% Need to find out whether something should be done with PM fit
        %%%% to determine warm and cold threshold - to be added
        cold_threshold = Results.threshold;
        cold_seThreshold = Results.seThreshold;
        cold_slope = Results.slope;
        cold_seSlope = Results.seSlope;
        
        load(filename_warm)
        warm_threshold = Results.threshold;
        warm_seThreshold = Results.seThreshold;
        warm_slope = Results.slope;
        warm_seSlope = Results.seSlope;
        
        if plot == true % plot each
            figure(1)
            plot(cold_threshold);
            hold on
            plot(cold_threshold - cold_seThreshold)
            hold on
            plot(cold_threshold + cold_seThreshold)
            title(sprintf('Cold Threshold %s, %s', subject, session))
            xlabel('Trial N')
            
            figure(2)
            plot(warm_threshold)
            hold on
            plot(warm_threshold - warm_seThreshold)
            hold on
            plot(warm_threshold + warm_seThreshold)
            title(sprintf('Warm Threshold %s, %s', subject, session))
            xlabel('Trial N')
        
            % save both figures
            figname1 = fullfile(path, project, subject, session, datatype, [subject '_' session '_task-' task_name '_cold' '.png']);
            saveas(figure(1), figname1);
            figname2 = fullfile(path, project, subject, session, datatype, [subject '_' session '_task-' task_name '_warm' '.png']);
            saveas(figure(2), figname2);
        end
        
        % make the data-frame (all trials)
        n = length(cold_threshold) + length(warm_threshold);
        sub = repmat(sub_n,n,1);
        ses = repmat(ses_n,n,1);
        task = repmat(task_name,n,1);
        datatype = repmat(datatype,n,1);
        trial_n = [transpose(1:length(cold_threshold)); transpose(1:length(warm_threshold))];
        quality = [repmat('cold',length(cold_threshold),1); repmat('warm',length(cold_threshold),1)]; 
        threshold = [cold_threshold; warm_threshold];
        threshold_se = [cold_seThreshold; warm_seThreshold];
        slope = [cold_slope; warm_slope];
        slope_se = [cold_seSlope; warm_seSlope];

        % create table
        df = table(sub, ses, task, datatype, trial_n, quality, threshold, threshold_se, slope, slope_se);
         
%         % make the data-frame (threshold values)
%         n = 2;
%         sub_n = repmat(sub_n,n,1);
%         ses_n = repmat(ses_n,n,1);
%         task = repmat(task_name,n,1);
%         datatype = repmat(datatype,n,1);
%         quality = ['cold'; 'warm']; 
%         threshold = [cold_threshold(end); warm_threshold(end)];
%         se = [cold_se(end); warm_se(end)];
%         
%         % create table
%         df = table(sub_n, ses_n, task, datatype, quality, threshold, se);
        % write tsv file
        writetable(df,filename,'FileType','text','Delimiter','\t');
    else
        fprintf('Psi threshold source data does not exist for %s %s\n', subject, session)
        df = [];
    end
    close all
end