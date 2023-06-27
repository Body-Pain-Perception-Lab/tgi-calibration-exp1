function t = vas2tsv(path, project, sub_n, ses_n, task, datatype, fast_data)
% VAS2TSV generate tsv files based on matalab source data containing vas
% ratings results
    subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
    session = ['ses-' num2str(ses_n,'%02.f')]; % Define session
    
    task_ori = task;
    task = 'vas';
    
    % filenames
    %filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'session '_' 'task-' task '_' datatype]); % how it should be
    filename_source = fullfile(path, project, 'sourcedata', subject, session, [subject '_' 'ses-session' num2str(ses_n) '_' 'task-' task_ori '_' datatype '.mat']); % temporary fix
    filename = fullfile(path, project, subject, session, datatype, [subject '_' session '_' 'task-' task '_' datatype '.tsv']); % how it should be
   
    % Check source data and generate tsv
    if isfile(filename_source)
        load(filename_source)
        res = Results;
        
        % TCS data
        for i = 1:size(res.tcsData,1)
            tcs(i,:) = res.tcsData{i}(end,3:7);
        end
        % Make table
        sub_n = repmat(sub_n,length(res.targetTcold),1);
        ses_n = repmat(ses_n,length(res.targetTcold),1);
        task = repmat(task,length(res.targetTcold),1);
        datatype = repmat(datatype,length(res.targetTcold),1);
        trial_n = transpose(1:length(res.targetTcold));
        
        target_cold = round(res.targetTcold,1);
        target_warm = round(res.targetTwarm,1);
        temp1 = tcs(:,1);
        temp2 = tcs(:,2);
        temp3 = tcs(:,3);
        temp4 = tcs(:,4);
        temp5 = tcs(:,5);
        vas_cold = res.vasResponse(:,1);
        vas_warm = res.vasResponse(:,2);
        vas_burn = res.vasResponse(:,3);
        rt_vas_cold = res.vasReactionTime(:,1);
        rt_vas_warm = res.vasReactionTime(:,2);
        rt_vas_burn = res.vasReactionTime(:,3);

        % create table with VAS rating data
        t1 = table(sub_n, ses_n, task, datatype, trial_n, target_cold, target_warm, temp1, temp2, temp3, temp4, temp5, vas_cold, vas_warm, vas_burn, rt_vas_cold, rt_vas_warm, rt_vas_burn);
     
        % get data from vas (temperature pairs)
        temp_pairs = round(unique([res.targetTcold res.targetTwarm],'rows'), 1); % get temperature pairs used for the VAS ratings
        
        % get data from fast (threshold functions)
        temp_fast_25 = round([fast_data.tcold fast_data.twarm_25], 1); % get 25% threshold function data (fast) and round them to one decimal
        temp_fast_50 = round([fast_data.tcold fast_data.twarm_50], 1); % get 50% threshold function data (fast) and round them to one decimal
        temp_fast_75 = round([fast_data.tcold fast_data.twarm_75], 1); % get 75% threshold function data (fast) and round them to one decimal

        % identify which temps correspond to which threshold functions 
        tf_25 = intersect(temp_pairs,temp_fast_25,'rows');
        tf_50 = intersect(temp_pairs,temp_fast_50,'rows');
        tf_75 = intersect(temp_pairs,temp_fast_75,'rows');
        
        %% Fix subjects
        % session 1
        if sub_n(1) == 12 && ses_n(1) == 1
            tf_25 = [4.2 42.9; 8.5 43.4; 12.7 44];   
        elseif sub_n(1) == 14 && ses_n(1) == 1 
            tf_25 = [24.6 35.8; 25.5 37.6; 26.5 39.7];
            tf_50 = [23.8 40.3; 24.1 40.9; 24.3 41.3];
        elseif sub_n(1) == 15 && ses_n(1) == 1
            tf_25 = [14.1 43.8; 17.6 44.3; 21 45.1];
        elseif sub_n(1) == 21 && ses_n(1) == 1
            tf_25 = [16.8 31.2; 20.9 32.8; 24.9 34.5];
            tf_50 = [7.7 35.9; 14.8 37.6; 21.9 40.2];
            tf_75 = [3.5 42.5; 6.5 42.8; 9.4 43.3];
        end


        % session 2
        if sub_n(1) == 3 && ses_n(1) == 2
            tf_25 = round([17.8 33.1; 21.5 36.1; 25.3 39.1],1);
            tf_50 = round([15.9 33.6; 20.3 37.2; 24.6 40.6],1);
            tf_75 = round([13.8 34; 18.4 37.8; 23.1 41.6],1);
        elseif sub_n(1) == 4 && ses_n(1) == 2
            tf_25 = round([14 33.9; 17.8 37.6; 21.6 41.1],1);
        elseif sub_n(1) == 5 && ses_n(1) == 2
            tf_25 = round([12.3 34.4; 17.9 37.5; 23.4 40],1);
            tf_50 = round([9.8 40; 12.8 41.9; 15.9 43.7],1);
            tf_75 = round([6.9 44.9; 7 45; 7.2, 45.2],1);
        elseif sub_n(1) == 6 && ses_n(1) == 2
            tf_25 = round([18.1 32.5; 21.8 35.3; 25.4 38.1],1);
            tf_75 = round([7.1 37; 10.3 38.9; 13.6 41],1);
        end

        %% create table for temperature pairs correspondinf to 25% threshold function 
        if ~isempty(tf_25)
            n = size(tf_25,1) * 3;
            trial_type = repelem(["tgi"; "cold"; "warm"],n/3,1);
            tf = repmat(25,n,1);
            lf = transpose(repmat(1:n/3,1,3));
            target_cold = [tf_25(:,1); tf_25(:,1); repmat(30,n/3,1)];
            target_warm = [tf_25(:,2); repmat(30,n/3,1); tf_25(:,2);];
            t25 = table(trial_type, tf, lf, target_cold, target_warm);
        else
            t25 = [];
        end

        % create table for temperature pairs correspondinf to 50% threshold function 
        if ~isempty(tf_50)
            n = size(tf_50,1) * 3;
            trial_type = repelem(["tgi"; "cold"; "warm"],n/3,1);
            tf = repmat(50,n,1);
            lf = transpose(repmat(1:n/3,1,3));
            target_cold = [tf_50(:,1); tf_50(:,1); repmat(30,n/3,1)];
            target_warm = [tf_50(:,2); repmat(30,n/3,1); tf_50(:,2);];
            t50 = table(trial_type, tf, lf, target_cold, target_warm);
        else
            t50 = [];
        end
        
        % create table for temperature pairs correspondinf to 75% threshold function 
        if ~isempty(tf_75)
            n = size(tf_75,1) * 3;
            trial_type = repelem(["tgi"; "cold"; "warm"],n/3,1);
            tf = repmat(75,n,1);
            lf = transpose(repmat(1:n/3,1,3));
            target_cold = [tf_75(:,1); tf_75(:,1); repmat(30,n/3,1)];
            target_warm = [tf_75(:,2); repmat(30,n/3,1); tf_75(:,2);];
            t75 = table(trial_type, tf, lf, target_cold, target_warm);
        else
            t75 = [];
        end
        
        % concatenate table with condition labels
        t2 = [t25; t50; t75];

        % merge t1 (condition labels) and t2 (VAS rating results)
        t = outerjoin(t1,t2);
        t = sortrows(t, 'trial_n'); % re-order by trial number
        
        if any(isnan(t.target_cold_t2)) || any(isnan(t.target_warm_t2)) 
            % print warning message and do not save dataframe
            fprintf(2,'Not all temperature pairs correspond to a threshold function for %s %s\n', subject, session)
%         elseif size(t,1) ~= size(t1,1) || size(t,2) ~= size(t1,2) + size(t2,2) 
%             fprintf(2, 'Data frames are not consistent for %s %s\n', subject, session)

%             idx = [];
%             for i = 1:size(t1,1)
%                 if sum(t.trial_n == i) > 1 % find duplicates
%                     trial_repeated = find(t.trial_n == i);
%                     idx = [idx; trial_repeated];
%                 end
%             end

        else
            % write tsv file
            writetable(t,filename,'FileType','text','Delimiter','\t');
        end
    else
        fprintf('VAS rating source data does not exist for %s %s\n', subject, session)
        t = [];
    end 
end