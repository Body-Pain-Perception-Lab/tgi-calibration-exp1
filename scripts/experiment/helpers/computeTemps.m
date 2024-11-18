function [TcoldTGI, TwarmTGI]=computeTemps (vars,granularity,prob)%, coldPainThr, warmPainThr]=computeTemps (vars,granularity,prob,painRange)

try
    %%
    try %Try loading data from this session. If not available, try session 1
        name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-fasttgi_beh.mat');
        out1 = load(strcat(vars.dir.OutputFolder,name));
    catch
        name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-fasttgi_beh.mat');
        out1 = load(strcat(vars.dir.OutputFolder,name));
    end
    
%     switch vars.control.whichMethodCW
%         case 1 % loads Psi Results
%             try %Try loading data from this session. If not available, try session 1
%                 name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-psipain_beh.mat');
%                 out2 = load(strcat(vars.dir.OutputFolder,name));
%             catch
%                 name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-psipain_beh.mat');
%                 out2 = load(strcat(vars.dir.OutputFolder,name));
%             end
%         otherwise
%             try %Try loading data from this session. If not available, try session 1
%                 name = strcat('sub-',vars.ID.subIDstring,'_ses-session',vars.ID.sesIDstring,'_task-limitspain_beh.mat');
%                 out2 = load(strcat(vars.dir.OutputFolder,name));
%             catch
%                 name = strcat('sub-',vars.ID.subIDstring,'_ses-session',num2str(1),'_task-limitspain_beh.mat');
%                 out2 = load(strcat(vars.dir.OutputFolder,name));
%             end
%     end
    
    myfast = out1.Results.myfast;
    
    if out1.thisTrial == out1.vars.task.NTrialsTotal
        myfast.params.est = out1.Results.estimate{end};
    else
        myfast.params.est = fastEstimate(myfast, [0.25, 0.5 0.75], 1,1); %so the code does not break if not all 100 trials from task 1 were collected
    end
    
    %Extract values for the selected probabilities.
    allTcold = out1.vars.task.Tmin:0.1:out1.vars.task.Tcoldmax;
    
%     switch vars.control.whichMethodCW
%         case 1
%             cpt_params = psiFitPlot(out2.Results(1), 'CPT');
%             wpt_params = psiFitPlot(out2.Results(2), 'HPT');
%             PF_cpt = out2.Results(1).PM.PF;
%             PF_wpt = out2.Results(2).PM.PF;
% 
%             coldPainThr=PF_cpt(cpt_params, 1-painRange, 'inverse');
%             warmPainThr=PF_wpt(wpt_params, painRange, 'inverse');
%             
%             if coldPainThr<=out2.vars.task.Tmin
%                 fprintf('CPT was %f. Set to %f for safety reasons \n',coldPainThr,out2.vars.task.Tmin)
%                 coldPainThr =out2.vars.task.Tmin;
%             end
%             if warmPainThr>=out2.vars.task.Tmax
%                 fprintf('HPT was was %f. Set to %f for safety reasons \n',warmPainThr,out2.vars.task.Tmax)
%                 warmPainThr = out2.vars.task.Tmax;
%             end
%             
%         otherwise
%             coldPainThr=mean(cell2mat(out2.Results(1).thresholdMean(6:end))); % loads Method of Limits results
%             warmPainThr=mean(cell2mat(out2.Results(2).thresholdMean(6:end)));%Discard first 5 trials
%     end
    
    TcoldTGI =NaN(length(prob),granularity);
    TwarmTGI =NaN(length(prob),granularity);
    for i=1:length(prob) %Probability
        for j=1:granularity %Granularity
            TwarmInThr = squeeze(fastCalcYs(myfast,allTcold,prob(i),'margMean'));
            
            %Start
            coldRange = allTcold;
            warmRange = TwarmInThr;
            
            %Remove pain values and when Twarm <Tbaseline or Twarm>Tmax
            remove_idx=(warmRange>=out1.vars.task.Tmax | warmRange<out1.vars.task.Tbaseline);
%             remove_idx= (coldRange<=max(out1.vars.task.Tmin,coldPainThr-2)) | (warmRange>=min(out1.vars.task.Tmax,warmPainThr+2)) | (warmRange<out1.vars.task.Tbaseline);
            coldRange(remove_idx)=[];
            warmRange(remove_idx)=[];
            
%             %Remove repeated values
%             coldRange = unique(coldRange);
%             warmRange = unique(warmRange);
            
            try
            % picking the borders    
%                 if isequal(j,1)
%                     idx = 1;
%                 else
%                     idx = round(length(coldRange)*(j-1)/(granularity-1));
%                 end
            % excluding the borders
                idx = round(length(coldRange)*j/(granularity+1));

                TcoldTGI(i,j) = single(round(coldRange(idx),1));
                TwarmTGI(i,j) = single(round(warmRange(idx),1));
            catch
                % No points of the equiprobable curve within the TGI region.
                if isequal(sum(TwarmInThr<=warmPainThr),0)
                    TcoldTGI(i,j) =out2.vars.task.Tmin;
                    TwarmTGI(i,j) =out2.vars.task.Tmax;
                else 
                    TcoldTGI(i,j) =out1.vars.task.Tbaseline;
                    TwarmTGI(i,j) =out1.vars.task.Tbaseline;
                end
            end
        end
    end
    
    
catch
    error('Results from previous parts of the experiment are missing or with very few trials.')
end

end