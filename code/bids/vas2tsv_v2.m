function t = vas2tsv_v2(path, project, sub_n, ses_n, task, datatype)
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
        out = load(filename_source);
        %res = Results;
        
        % Temperature pairs
        TcoldTGI  = out.vars.task.TcoldTGI;
        TwarmTGI  = out.vars.task.TwarmTGI;
        Tbaseline = out.vars.task.Tbaseline;

        % Find idx
        idx_TGI = arrayfun(@(x,y) find(out.Results.targetTcold == x & out.Results.targetTwarm == y), TcoldTGI, TwarmTGI, 'UniformOutput',false);
        idx_cold = arrayfun(@(x) find(out.Results.targetTcold == x & out.Results.targetTwarm == Tbaseline), TcoldTGI, 'UniformOutput',false);
        idx_warm = arrayfun(@(x) find(out.Results.targetTcold == Tbaseline & out.Results.targetTwarm == x), TwarmTGI, 'UniformOutput',false);

        % Create repetitionN array
        idx_TGImat = [idx_TGI{:}];
        idx_Coldmat = [idx_cold{:}];
        idx_Warmmat = [idx_warm{:}];

        repetitionN =zeros(out.vars.task.NTrialsTotal,1);
        for i=1:(out.vars.task.NTrialsTotal/length(out.vars.task.gain)/length(out.vars.fast.pArray)/3)
            repetitionN(idx_TGImat(i,:))=i;
            repetitionN(idx_Coldmat(i,:))=i;
            repetitionN(idx_Warmmat(i,:))=i;
        end

        % Create thresholdP array
        thresholdP =zeros(out.vars.task.NTrialsTotal,1);
        for i=1:length(out.vars.fast.pArray)
            idx_TGIpmat = [idx_TGI{i,:}];
            idx_Coldpmat = [idx_cold{i,:}];
            idx_Warmpmat = [idx_warm{i,:}];
            
            thresholdP(idx_TGIpmat(:)) = out.vars.fast.pArray(i);
            thresholdP(idx_Coldpmat(:)) = out.vars.fast.pArray(i);
            thresholdP(idx_Warmpmat(:)) = out.vars.fast.pArray(i);
        end

        % Create gainFrac array
        gainFrac =ones(out.vars.task.NTrialsTotal,1);
        for i=1:length(out.vars.task.gain)
            idx_TGIgmat = [idx_TGI{:,i}];
            idx_Coldgmat = [idx_cold{:,i}];
            idx_Warmgmat = [idx_warm{:,i}];
            
            gainFrac(idx_TGIgmat(:)) =out.vars.task.gain(i);
            gainFrac(idx_Coldgmat(:)) =out.vars.task.gain(i);
            gainFrac(idx_Warmgmat(:)) =out.vars.task.gain(i);
        end

        %Create quality array
        StimType = cell(out.vars.task.NTrialsTotal,1);
        StimType (idx_TGImat(:))  = {'tgi'};
        StimType (idx_Coldmat(:)) = {'cold'};
        StimType (idx_Warmmat(:)) = {'warm'};

        % TCS data
        for i = 1:size(out.Results.tcsData,1)
            tcs(i,:) = out.Results.tcsData{i}(end,3:7);
        end
        
        % Define variables
        n = out.vars.task.NTrialsTotal; % Number of VAS ratings
        m = 3; % number of ratings per trial

        % Create variables for table
        sub_n       = repmat(sub_n,n*m,1);
        ses_n       = repmat(ses_n,n*m,1);
        task        = repmat(task,n*m,1);
        datatype    = repmat(datatype,n*m,1);
        trial_n     = repmat(transpose(1:n),3,1);
        rep_n       = repmat(repetitionN,3,1); 
        target_cold = repmat(out.Results.targetTcold,3,1);
        target_warm = repmat(out.Results.targetTwarm,3,1);
        temp1       = repmat(tcs(:,1),3,1);
        temp2       = repmat(tcs(:,2),3,1);
        temp3       = repmat(tcs(:,3),3,1);
        temp4       = repmat(tcs(:,4),3,1);
        temp5       = repmat(tcs(:,5),3,1);
        threshold   = repmat(thresholdP,3,1);
        gain        = repmat(gainFrac,3,1);
        stim_type   = repmat(StimType,3,1);
        vas_type    = [repmat('cold',out.vars.task.NTrialsTotal,1);repmat('warm',out.vars.task.NTrialsTotal,1);repmat('burn',out.vars.task.NTrialsTotal,1)];                   
        vas_rating  = out.Results.vasResponse(:);
        vas_rt      = out.Results.vasReactionTime(:);

        % create table with VAS rating data
        t = table(sub_n, ses_n, task, datatype, trial_n, rep_n, target_cold, target_warm, temp1, temp2, temp3, temp4, temp5, threshold, gain, stim_type, vas_type, vas_rating, vas_rt);

        % write table
        writetable(t,filename,'FileType','text','Delimiter','\t');
    else
        fprintf('VAS rating source data does not exist for %s %s\n', subject, session)
        t = [];
    end 
end

