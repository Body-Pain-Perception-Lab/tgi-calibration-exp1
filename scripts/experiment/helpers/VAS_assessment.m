%  Define vars for MultiDim
clear all
close all
vars.dir.projdir = "C:\Users\mgane\Documents\Camila\GitHub\Multidim_Thr";
vars.control.whichMethodCW = 1;
vars.fast.pArray = [0.25 0.5 0.75];
vars.task.gain = [0.25 0.5 0.75];
vars.task.Tbaseline=30;

Check_VAS(vars,43,1)

function Check_VAS(vars, sub_n, ses_n)

% First load files specific to each participant
subject = ['sub-' num2str(sub_n,'%04.f')]; % Define subject 
session = ['session' num2str(ses_n,'%1.f')]; % Define session

vars.ID.subIDstring = sprintf('%04d', sub_n);
vars.ID.sesIDstring = sprintf('%d', ses_n);
%BIDS
% session = ['ses-' num2str(ses_n,'%02.f')]; % Define session

vars.dir.OutputFolder = fullfile(vars.dir.projdir, 'data', subject, filesep);
        

datatype='beh';
%% Read in all data

% Load pain threshold files
pain_name = 'psipain';

% % in BIDS format
% file_coldP = fullfile(vars.dir.OutputFolder,...
%    [subject '_' session '_' 'task-' pain_name 'cold_' datatype '.mat']); % MAT file to read in
% file_heatP = fullfile(vars.dir.OutputFolder,...
%    [subject '_' session '_' 'task-' pain_name 'warm_' datatype '.mat']); % MAT file to read in

% currently data not saved in BIDS format
file_coldP = fullfile(vars.dir.OutputFolder,...
   [subject '_ses-' session '_' 'task-' pain_name 'cold_' datatype '.mat']); % MAT file to read in
file_heatP = fullfile(vars.dir.OutputFolder,...
   [subject '_ses-' session '_' 'task-' pain_name 'warm_' datatype '.mat']); % MAT file to read in

% Load pain threshold files
fast_name = 'fasttgi';

% % in BIDS format
% file_multi = fullfile(vars.dir.OutputFolder,...
%    [subject '_' session '_' 'task-' pain_name '_' datatype '.mat']); % MAT file to read in

% currently data not saved in BIDS format
file_multi = fullfile(vars.dir.OutputFolder,...
   [subject '_ses-' session '_' 'task-' fast_name '_' datatype '.mat']); % MAT file to read in


%% cold pain
% load data
if isfile(file_coldP)
    pain_cold = load(file_coldP);

    % fit and plot function
    cpt_params = psiFitPlot(pain_cold, 'CPT');
    if ~isempty(cpt_params)
        % save figure
        fig_name = sprintf('%s_%s_%s_CPTfit.png', subject, session, pain_name);
        fig_loc = fullfile(vars.dir.OutputFolder, fig_name);
        saveas(figure(3),fig_loc)
    end

%     % extract params
%     cpt_slope = 1/(10^pain_cold.Results.PM.slope(end)); % extract the sigma of the slope (inverse log10)
%     cpt_thresh = pain_cold.Results.PM.threshold(end); % threshold

else
    new_line;
    fprintf('No psi cold pain thresholding data found for %s', subject);
end

%% heat pain
% load data
if isfile(file_heatP)
    pain_heat = load(file_heatP);

    % fit and plot function
    hpt_params = psiFitPlot(pain_heat, 'HPT');
    if ~isempty('hpt_params')
        % save figure
        fig_name = sprintf('%s_%s_%s_HPTfit.png', subject, session, pain_name);
        fig_loc = fullfile(vars.dir.OutputFolder, fig_name);
        saveas(figure(4),fig_loc)
    end
    
%   % extract params
%     hpt_slope = 1/(10^pain_heat.Results.PM.slope(end)); % extract the sigma of the slope (inverse log10)
%     hpt_thresh = pain_heat.Results.PM.threshold(end); % threshold


else
    new_line;
    fprintf('No psi heat pain thresholding data found for %s', subject);
end

%% Make cold and warm temperature continuums
if isfile(file_multi)
    multi_tgi  = load(file_multi);
    vars.fast.myfast = multi_tgi.Results.myfast;
    vars.fast.myfast.params.est = multi_tgi.Results.estimate{end};
    
    [Tcold, Twarm, coldPainThr, warmPainThr]= computeTGItemps(vars,vars.task.gain,vars.fast.pArray);
    figure(5)
    for i=1:length(vars.fast.pArray)
        hold on
        allTcold = multi_tgi.vars.task.Tmin:0.1:multi_tgi.vars.task.Tcoldmax;
        TwarmInThr = squeeze(fastCalcYs(vars.fast.myfast,allTcold,vars.fast.pArray(i),'margMean'));
        
        
        plot(allTcold,TwarmInThr,'k','LineWidth',3)
        axis([multi_tgi.vars.task.Tmin multi_tgi.vars.task.Tbaseline multi_tgi.vars.task.Tbaseline multi_tgi.vars.task.Tmax])
        
        %                 % Plot HPT and CPT
        %                 [value,idx]=min(abs(TwarmInThr-warmPainThr(i)));
        %                 if value >1
        %                     idx = length(TwarmInThr);
        %                 end
        %                 scatter(allTcold(idx),TwarmInThr(idx),50,'r','filled')
        %                 if coldPainThr(i)>0
        %                    [~,idx]=min(abs(allTcold-coldPainThr(i)));
        %                 else
        %                    [~,idx]=min(abs(allTcold-0));
        %                 end
        %                 scatter(allTcold(idx),TwarmInThr(idx),50,'b','filled')
        % %                 title (['session ' vars.ID.sesIDstring])
        
        yline(warmPainThr(i),'r-','LineWidth',3) %Does not work anymore with one value for each
        xline(coldPainThr(i),'b-','LineWidth',3)
    end
    scatter(Tcold(:),Twarm(:),50,'k','filled')
    
    %             yline(warmPainThr,'r-','LineWidth',3) %Does not work anymore with one value for each
    %             xline(coldPainThr,'b-','LineWidth',3)
    
    
    sgtitle(['Subject ' vars.ID.subIDstring])
    
    % save figure
    fig_name = sprintf('%s_%s_%s_VASfit.png', subject, session, fast_name);
    fig_loc = fullfile(vars.dir.OutputFolder, fig_name);
    saveas(figure(5),fig_loc)
else
    new_line;
    fprintf('No FAST TGI data found for %s', subject);
end

end

