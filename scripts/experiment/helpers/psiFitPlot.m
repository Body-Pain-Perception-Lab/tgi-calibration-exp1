function paramsValues = psiFitPlot(dat, name)
%% Fits a psychometric curve for psi adaptive temperature thresholding
% A G Mitchell - 22.07.2023
% Project: MultiDim-Thr and tgi-mri

% dat = structure input with psi parameters
% name = string with name of stimuli being fitted

% define function
PF = dat.PM.PF;

% define trial parameters - fix to handle missing data
[numPos idxtoremove] = rmmissing(dat.PM.response);
stimLevels = dat.PM.x(1:end-1);
stimLevels = stimLevels(not(idxtoremove));
outOfNum = ones(1,length(numPos));
paramsFree = [1 1 0 0];

% stimLevels = dat.PM.x(1:end-1);
% numPos = dat.PM.response;
% outOfNum = ones(1,length(numPos));
% paramsFree = [1 1 0 0];

% define search space
searchGrid.alpha = dat.PM.priorAlphaRange;
searchGrid.beta = dat.PM.priorBetaRange;
searchGrid.gamma = dat.PM.priorGammaRange;
searchGrid.lambda = dat.PM.priorLambdaRange;  

% fit function
[paramsValues, LL, exitFlag] = PAL_PFML_Fit(stimLevels, numPos, outOfNum,...
    searchGrid, paramsFree, PF);

% plot function, purely for visualisation purposes
stimLevelsFine = [min(stimLevels):(max(stimLevels) - min(stimLevels))./1000:max(stimLevels)];
Fit = PF(paramsValues, stimLevelsFine);

% if exit flag does not = 1, fit unsuccessful
if exitFlag ~= 1
    new_line;
    fprintf('Fit for %s psi thresholding was not possible, parameter values will be empty and only threshold used', name);

    paramsValues = [];
else
    % making plot
    switch name % changing colour based on cold/warm
        case 'CDT'
            figure(1)
            plot(stimLevelsFine, Fit, 'b-', 'LineWidth', 3)
        case 'CPT'
            figure(3)
            plot(stimLevelsFine, Fit, 'b-', 'LineWidth', 3)
        case 'WDT'
            figure(2)
            plot(stimLevelsFine, Fit, 'r-', 'LineWidth', 3)
        case 'HPT'
            figure(4)
            plot(stimLevelsFine, Fit, 'r-', 'LineWidth', 3)
    end
    hold on
    plot(stimLevels, numPos, 'k.', 'MarkerSize', 30)
    hold on
    % plot threshold
    xline(paramsValues(1), 'k--', 'LineWidth', 2)
    set(gca, 'fontsize', 12);
    ylabel('Inverse proportion correct')
    xlabel('Temperature (°C)')
    title(sprintf('%s', name), 'FontSize', 14)
end
end