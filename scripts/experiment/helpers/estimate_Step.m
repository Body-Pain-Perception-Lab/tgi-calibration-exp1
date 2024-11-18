%% estimate Cold and Warm Intervals from AM data
clear all
close all
clc

cd ('\\hyades00.pet.auh.dk\aux\MINDLAB2022_MR-SensCognThermalPainPercep')

prob = [0.25 0.5 0.75];
for subject =2:17
    
    cd (['sub-' sprintf('%04d',subject)])
    
    cd ('ses-01')
   
    
    cd ('beh')
    
    cd ('02_thr_pain')
    coldResults = load (['sub-' sprintf('%04d',subject) '_ses-01_task-psipaincold_beh.mat']);
    heatResults = load (['sub-' sprintf('%04d',subject) '_ses-01_task-psipainwarm_beh.mat']);
    
    try
        
        cpt_params = psiFitPlot(coldResults.Results, 'CPT');
        cpt_slope = 1/(10^cpt_params(2));
        PF_cpt = coldResults.Results.PM.PF;
%         if cpt_slope <2
            coldPainThr(subject,:)=PF_cpt(cpt_params, 1-prob, 'inverse');
%         else
%             coldPainThr(subject,:)= PF_cpt([coldResults.Results.PM.threshold(end) coldResults.Results.PM.slope(end) coldResults.Results.PM.guess(end) coldResults.Results.PM.lapse(end)], 1-prob, 'inverse')
%             cpt_slope = 1/(10^coldResults.Results.PM.slope(end));
%             if 
%                 coldPainThr(subject,:)=NaN(size(prob));
%             end
%         end
    catch 
        coldPainThr(subject,:)=NaN(size(prob));
    end
    
    try
        hpt_params = psiFitPlot(heatResults.Results, 'HPT');
        hpt_slope = 1/(10^hpt_params(2));
%         hpt_slope = 1/(10^heatResults.Results.PM.slope(end));
        PF_hpt = heatResults.Results.PM.PF;
%         if hpt_slope <2
            heatPainThr(subject,:)=PF_hpt(hpt_params, prob, 'inverse');
%         else
%             heatPainThr(subject,:)=NaN(size(prob));
%         end
    catch 
        heatPainThr(subject,:)=NaN(size(prob));
    end
    
    cd ..
    cd ..
    cd ..
    cd ..
end

%%
a= diff(heatPainThr,[],2);
median(rmmissing(a(2:end,1)))

b= diff(coldPainThr,[],2);
median(rmmissing(b(2:end,1)))