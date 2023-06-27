%% Script to import source data and generate tsv files for analyses

path =  '/Users/au342995/Documents';
project = 'MINDLAB2022_CalibrationTGI';
subject = 1:28; 
session = 1:2;
datatype = 'beh';

%% Dependencies
addpath(genpath(fullfile(path, project, 'code', 'fast-toolbox')))

%% Pipeline

for sub_n = subject
    for ses_n = session
        bidsfolder(path, project, sub_n, ses_n, datatype) % check/make BIDS folders
        thr = thr2tsv(path, project, sub_n, ses_n, 'fasttgi', datatype); % fast multi-threshold data 
        res = res2tsv(path, project, sub_n, ses_n, 'fasttgi', datatype); % trial-by-trial response data
        psi = psi2tsv(path, project, sub_n, ses_n, 'psipain', datatype); % psi threshold data
        vas = vas2tsv_v1(path, project, sub_n, ses_n, 'vastgi', datatype, thr);  % VAS rating data
    end
end





    
