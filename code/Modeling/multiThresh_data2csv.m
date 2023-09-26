%% add toolbox to path

clear all
sub_n ={'0003','0004','0005','0006','0008','0011','0016','0017','0018','0020','0021','0022','0024','0025','0026'};
cd '/Users/au706606/Downloads/sourcedata'

A=[];
B=[];
C=[];

for i=1:length(sub_n)
    
    cd(['sub-' sub_n{i}])
    cd('ses-01')
    out1 = load(['sub-' sub_n{i} '_ses-session1_task-fasttgi_beh.mat']);
    try
        out2 = load(['sub-' sub_n{i} '_ses-session1_task-psipain_beh.mat']); %Use the try only if you intend to extract data from session 2
    catch
        out2 = load(['sub-' sub_n{i} '_ses-session1_task-psipain_beh.mat']);
    end
    
    cd ..
    cd ..
        
    %% Define trial by trial responses 
    A1 = [out1.Results.targetTwarm out1.Results.targetTcold out1.Results.Response];
    A2 = repmat(str2num(sub_n{i}), length(A1),1);
    A_sub = [A2 A1];
    A = [A; A_sub];
    
    %% Get Threshold data
    
    % Method of Limits
%     [B1, B2] = out2.Results.thresholdMean;
%     cpt = mean(cell2mat(B1(6:10)));
%     hpt = mean(cell2mat(B2(6:10)));
%     B_sub = [subN cpt hpt];
%     B = [B; B_sub];
    
    % Psi
    [B1, B2] = out2.Results.threshold;
    cpt = B1(end);
    hpt = B2(end);
    B_sub = [str2num(sub_n{i}) cpt hpt];
    B = [B; B_sub];
    
    %% Get threshold function data
    fast=out1.Results.myfast;
    fast.params.est=out1.Results.estimate{end};
    tcold=0:0.1:29;
    twarm_25 = squeeze(fastCalcYs(fast,tcold,0.25,'margMean'));
    twarm_50 = squeeze(fastCalcYs(fast,tcold,0.5,'margMean'));
    twarm_75 = squeeze(fastCalcYs(fast,tcold,0.75,'margMean'));
    
    C1 = [tcold' twarm_25' twarm_50' twarm_75'];
    C2 = repmat(str2num(sub_n{i}), length(C1),1);
    C_sub = [C2 C1];
    C = [C; C_sub];
    
end
T1 = array2table(A);
T1.Properties.VariableNames(1:5) = {'id', 'warmT','coldT','burn_yn', 'cold_warm'};
writetable(T1, 'responses.csv')

T2 = array2table(B);
T2.Properties.VariableNames(1:3) = {'id', 'cpt','hpt'};
writetable(T2, 'limits.csv')

T3 = array2table(C);
T3.Properties.VariableNames(1:5) = {'id', 'tcold','twarm_25','twarm_50','twarm_75'};
writetable(T3, 'thresholds.csv')
% %% Define trial by trial responses 
% A = [];
% for subN = [0 10 13 15 16 18]
%     filename1 = ['sub-' num2str(subN,'%04d') '_ses-session2_tgiMultiThr_part1.mat'];
%     load(filename1)
%     A1 = [Results.targetTwarm Results.targetTcold Results.Response];
%     A2 = repmat(subN, length(A1),1);
%     A_sub = [A2 A1];
%     A = [A; A_sub];
% end
% T1 = array2table(A);
% T1.Properties.VariableNames(1:5) = {'id', 'warmT','coldT','burn_yn', 'cold_warm'};
% writetable(T1, 'responses2.csv')
% %% Get methods of limits data
% B = [];
% for subN = [0 10 12 13 14 15 16 18]
%     filename2 = ['sub-' num2str(subN,'%04d') '_ses-session2_tgiMultiThr_part2Psi.mat'];
%     load(filename2)
%     [B1, B2] = Results.thresholdMean;
%     cpt = mean(cell2mat(B1(6:10)));
%     hpt = mean(cell2mat(B2(6:10)));
%     B_sub = [subN cpt hpt];
%     B = [B; B_sub];
% end
% T2 = array2table(B);
% T2.Properties.VariableNames(1:3) = {'id', 'cpt','hpt'};
% writetable(T2, 'limits2.csv')
% 
% %% Get threshold function data
% C = [];
% for subN = [0 10 12 13 14 15 16 18]
%     filename1 = ['sub-' num2str(subN,'%04d') '_ses-session2_tgiMultiThr_part2.mat'];
%     load(filename1)
%     
%     fast=Results.myfast;
%     fast.params.est=Results.estimate{end};
%     tcold=0:0.1:29;
%     twarm_25 = squeeze(fastCalcYs(fast,tcold,0.25,'margMean'));
%     twarm_50 = squeeze(fastCalcYs(fast,tcold,0.5,'margMean'));
%     twarm_75 = squeeze(fastCalcYs(fast,tcold,0.75,'margMean'));
%     
%     C1 = [tcold' twarm_25' twarm_50' twarm_75'];
%     C2 = repmat(subN, length(C1),1);
%     C_sub = [C2 C1];
%     C = [C; C_sub];
% end
% T3 = array2table(C);
% T3.Properties.VariableNames(1:5) = {'id', 'tcold','twarm_25','twarm_50','twarm_75'};
% writetable(T3, 'thresholds2.csv')

%%
plot(tcold,twarm_50)
xlabel ('Tcold')
ylabel('Twarm')
title('Threshold function at p=0.5')
