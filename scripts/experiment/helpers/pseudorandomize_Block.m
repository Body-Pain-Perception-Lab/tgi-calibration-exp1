function [TwarmSequence, TcoldSequence, StimTypeSequence, IntensitySequence] = pseudorandomize_Block (vars)

    StimProb = repmat(vars.fast.pArray',3,vars.task.granularity);
    StimType = [repmat(zeros(3,1),1,vars.task.granularity);...
        repmat(ones(3,1),1,vars.task.granularity);...
        repmat(2*ones(3,1),1,vars.task.granularity)]; % 0- cold, 1- warm, 2- TGI
    
    warmT = [vars.task.Tbaseline*ones(size(vars.task.TwarmTGI)); vars.task.TwarmTGI; vars.task.TwarmTGI];
    coldT = [vars.task.TcoldTGI; vars.task.Tbaseline*ones(size(vars.task.TcoldTGI)); vars.task.TcoldTGI];
    
    StimProbArray = StimProb(:);
    StimTypeArray = StimType(:);
    warmArray = warmT(:);
    coldArray = coldT(:);    

    IntensitySequenceCoding = 1:length(StimProbArray);
    %Code all intense trials the same, so they can't occur one after the other.
    isIntense = StimProbArray>vars.task.isIntenseLevel;
    CodenotToRepeat = length(StimProbArray)+1;
    IntensitySequenceCoding(isIntense) = CodenotToRepeat;

    idx = 1; %Start Value
    IntensitySequence(1) = 1; % StartValue
    LevelsToAvoid = unique(StimProbArray(IntensitySequenceCoding==CodenotToRepeat));

    while ~isempty(idx) | sum(IntensitySequence(1)==LevelsToAvoid)~=0 %continue until no repeats and first trial different from target
        Perm_idx = randperm(length(StimProbArray));  % shuffle array
        idx = unique(find(diff(IntensitySequenceCoding(Perm_idx))==0)); % find repeats
        IntensitySequence = StimProbArray(Perm_idx);
    end
    
    StimTypeSequence = StimTypeArray(Perm_idx);
    TwarmSequence = warmArray (Perm_idx);
    TcoldSequence = coldArray (Perm_idx);
end


% function [IntensitySequence, Perm_idx] = pseudorandomize_Block (InitialSequence,StimCoding,CodenotToRepeat)
% 
% %% Receives as input a sequence, an array that codes as the same all values that can't be adjacent to one another
% % Everything else should be coded differently.
%     idx = 1; %Start Value
%     IntensitySequence(1) = 1; % StartValue
%     LevelsToAvoid = unique(InitialSequence(StimCoding==CodenotToRepeat));
%     
%     while ~isempty(idx) | sum(IntensitySequence(1)==LevelsToAvoid)~=0 %continue until no repeats and first trial different from target
%         Perm_idx = randperm(length(InitialSequence));  % shuffle array   
%         idx = unique(find(diff(StimCoding(Perm_idx))==0)); % find repeats
%         IntensitySequence = InitialSequence(Perm_idx);
%         %StimTypeSequence = StimTypeSequence(Perm_idx);
%     end
% 
% end