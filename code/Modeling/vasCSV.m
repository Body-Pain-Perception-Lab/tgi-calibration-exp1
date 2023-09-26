
clear
sub_n ={'0003','0004','0005','0006','0008','0011','0016','0017','0018','0020','0021','0022','0024','0025','0026'};
cd '/Users/au706606/Downloads/sourcedata'

for i=1:length(sub_n)
    
    cd(['sub-' sub_n{i}])
    cd('ses-01')
    out4 = load(['sub-' sub_n{i} '_ses-session1_task-vastgi_beh.mat']);
    writeVasCSV (out4,sub_n{i})
    opts = detectImportOptions(['sub-' sub_n{i} '.csv']);
    newData = readtable(['sub-' sub_n{i} '.csv'],opts);
%     newData = csvread(['sub-' sub_n{i} '.csv']);
    
    cd ..
    cd ..
    
    if i==1
        allData =newData;
    else
        allData = vertcat(allData, newData);
    end
    
    % save back to file
    writetable(allData, ['allData.csv'])
end



function writeVasCSV (out,sub_n)
%Pairs
TcoldTGI = out.vars.task.TcoldTGI;
TwarmTGI = out.vars.task.TwarmTGI;
Tbaseline = out.vars.task.Tbaseline;

%Find idx
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
    
    thresholdP(idx_TGIpmat(:)) =out.vars.fast.pArray(i);
    thresholdP(idx_Coldpmat(:)) =out.vars.fast.pArray(i);
    thresholdP(idx_Warmpmat(:)) =out.vars.fast.pArray(i);
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
StimType (idx_TGImat(:))  = {'TGI '};
StimType (idx_Coldmat(:)) = {'Cold'};
StimType (idx_Warmmat(:)) ={'Warm'};

% vasResults = struct('SubID',            out.Results.SubID, ...
%                     'trialN',           (1:out.vars.task.NTrialsTotal)',...
%                     'repetitionN',      repetitionN,...
%                     'thresholdProb',    thresholdP,...
%                     'gainFract',        gainFrac,...
%                     'targetTwarm',      out.Results.targetTwarm,...
%                     'targetTcold',      out.Results.targetTcold,...
%                     'vasResponse',      out.Results.vasResponse,...
%                     'vasReactionTime',  out.Results.vasReactionTime);

vasResults = struct('SubID',                    repmat(out.Results.SubID,3,1), ...
                    'trialN',                   repmat((1:out.vars.task.NTrialsTotal)',3,1),...
                    'repetitionN',              repmat(repetitionN,3,1),...
                    'thresholdProb',            repmat(thresholdP,3,1),...
                    'gainFract',                repmat(gainFrac,3,1),...
                    'targetTwarm',              repmat(out.Results.targetTwarm,3,1),...
                    'targetTcold',              repmat(out.Results.targetTcold,3,1),...
                    'StimType',                 repmat(cell2mat(StimType),3,1),...
                    'StimDuration',             repmat(cellfun(@(a)a(end,2)-a(1,2),out.Results.tcsData),3,1),...
                    'vasType',                  [repmat('Cold',out.vars.task.NTrialsTotal,1);repmat('Warm',out.vars.task.NTrialsTotal,1);repmat('Burn',out.vars.task.NTrialsTotal,1)],...
                    'vasResponse',              out.Results.vasResponse(:),...
                    'vasReactionTime',          out.Results.vasReactionTime(:));

temp_table = struct2table(vasResults);
writetable(temp_table, ['sub-' sub_n '.csv'])

end

