function [TcoldTGI, TwarmTGI, coldPainThr, warmPainThr]=computeTGItemps (vars,gain,prob)

try
    %%
    try %Try loading data from this session. If not available, try session 1
        name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-fasttgi_beh.mat');
    catch
        name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-fasttgi_beh.mat');
    end
    out1 = load(strcat(vars.dir.OutputFolder,name));
    
    switch vars.control.whichMethodCW
        case 1 % loads Psi Results
            try %Try loading data from this session. If not available, try session 1
                name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psipain_beh.mat');
            catch
                name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-psipain_beh.mat');
            end
        otherwise
            try %Try loading data from this session. If not available, try session 1
                name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-limitspain_beh.mat');
            catch
                name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-limitspain_beh.mat');
            end
    end
    out2 = load(strcat(vars.dir.OutputFolder,name));
    
    myfast = out1.Results.myfast;
    
    myfast.params.est = out1.Results.estimate{end};
    
    %Extract values for the selected probabilities.
    allTcold = out1.vars.task.Tmin:0.1:out1.vars.task.Tcoldmax;
    
    switch vars.control.whichMethodCW
        case 1
            try
                cpt_params = psiFitPlot(out2.Results(1), 'CPT');
                PF_cpt = out2.Results(1).PM.PF;
                coldPainThr=PF_cpt(cpt_params, 1-prob, 'inverse');
            catch % if it does not fit, use threshold +/- constant to define ColdSpan
                ColdSpan=4;
                coldPainThr = linspace(out2.Results(1).PM.threshold(end)-ColdSpan,out2.Results(1).PM.threshold(end)+ColdSpan, length(gain));    
            end
            try 
                wpt_params = psiFitPlot(out2.Results(2), 'HPT');
                PF_wpt = out2.Results(2).PM.PF;          
                warmPainThr=PF_wpt(wpt_params, prob, 'inverse');
            catch % if it does not fit, use threshold +/- constant to define HeatSpan
                HeatSpan=1;
                warmPainThr = linspace(out2.Results(2).PM.threshold(end)-HeatSpan,out2.Results(2).PM.threshold(end)+HeatSpan, length(gain));
                
            end

        otherwise
            coldPainThr=mean(cell2mat(out2.Results(1).thresholdMean(6:end))) * ones(size(prob)); % loads Method of Limits results
            warmPainThr=mean(cell2mat(out2.Results(2).thresholdMean(6:end))) * ones(size(prob));%Discard first 5 trials
    end
    
    TcoldTGI =NaN(length(prob),length(gain));
    TwarmTGI =NaN(length(prob),length(gain));
    for i=1:length(prob) %Probability
        for j=1:length(gain) %Gain
            
            % Adjust cold and WarmPain Thr for safety
            if coldPainThr(i)<=out1.vars.task.Tmin
                fprintf('CPT was %f. Set to %f for safety reasons \n',coldPainThr(i),out1.vars.task.Tmin)
                coldPainThr(i) =out1.vars.task.Tmin;
            end
            if warmPainThr(i)>=out1.vars.task.Tmax
                fprintf('HPT was was %f. Set to %f for safety reasons \n',warmPainThr(i),out1.vars.task.Tmax)
                warmPainThr(i) = out1.vars.task.Tmax;
            end
            
             
            TwarmInThr = squeeze(fastCalcYs(myfast,allTcold,prob(i),'margMean'));
            
            %Start
            coldOutsidePain = allTcold;
            warmOutsidePain = TwarmInThr;
            
            %Remove pain values and when Twarm <Tbaseline
            remove_idx=(coldOutsidePain<=max(coldPainThr(i),0) | warmOutsidePain>=warmPainThr(i) | warmOutsidePain<vars.task.Tbaseline);
            coldOutsidePain(remove_idx)=[];
            warmOutsidePain(remove_idx)=[];
            
            %Remove repeated values
            coldOutsidePain = unique(coldOutsidePain);
            warmOutsidePain = unique(warmOutsidePain);
            
            try
                idx = round(length(coldOutsidePain)*gain(j));
                TcoldTGI(i,j) = single(round(coldOutsidePain(idx),1));
                TwarmTGI(i,j) = single(round(warmOutsidePain(idx),1));
            catch
                % No points of the equiprobable curve within the TGI region.
%                 if isequal(sum(TwarmInThr<=warmPainThr(i)),0)
                    TcoldTGI(i,j) =max(coldPainThr(i),out1.vars.task.Tmin);
                    TwarmTGI(i,j) = min(warmPainThr(i),out1.vars.task.Tmax);
%                     TcoldTGI(i,j) =out2.vars.task.Tmin;
%                     TwarmTGI(i,j) =out2.vars.task.Tmax;
%                 else 
%                     TcoldTGI(i,j) =out1.vars.task.Tbaseline;
%                     TwarmTGI(i,j) =out1.vars.task.Tbaseline;
%                 end
            end
        end
    end
    
    
catch
    error('Results from previous parts of the experiment are missing or with very few trials.')
end

end