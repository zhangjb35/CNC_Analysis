%% prep toolbox, functions and data
% zero the world
clear, clc
restoredefaultpath; %% set a clean path

% toolbox
home_dir = '/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis';
toolbox_dir = fullfile(home_dir, 'toolbox');
fuction_dir = fullfile(home_dir, 'functions');
addpath(fullfile(toolbox_dir, 'fieldtrip-20180922')); ft_defaults;
addpath(genpath(fullfile(toolbox_dir, 'eeglab14_1_2b')));

% function
addpath(genpath(fuction_dir));

% get raw effect data
effectRaw = kb_ls(fullfile(home_dir, 'data', 'effectRaw','*.mat'));
for i=1:length(effectRaw)
    tempData = load(effectRaw{i},'-mat');
    dataName = cell2mat(fieldnames(tempData));
    cfg = [];
    eval([ dataName '_avg = ft_freqgrandaverage(cfg,tempData.' dataName '{1:end})']);
    save([home_dir '/data/effectAVG/' dataName '_avg'],[dataName '_avg'])
end
clear *_avg

% get raw interaction effect data
intRaw = kb_ls(fullfile(home_dir, 'data', 'interactionRaw','*.mat'));
for i=1:length(intRaw)
    tempData = load(intRaw{i},'-mat');
    dataName = cell2mat(fieldnames(tempData));
    cfg = [];
    eval([ dataName '_avg = ft_freqgrandaverage(cfg,tempData.' dataName '{1:end})']);
    save([home_dir '/data/interactionAVG/' dataName '_avg'],[dataName '_avg'])
end
clear *_avg

% load and prep data
load('./data/effectAVG/MS_ML_avg.mat','-mat');
load('./data/effectAVG/OS_OL_avg.mat','-mat'); 
temp = MS_ML_avg;
temp.powspctrm =  temp.powspctrm - OS_OL_avg.powspctrm;
diff_map = temp;
clear temp
%% parameter setup
fronto_central_sites = {'AF7', 'AF3', 'AF4', 'AF8', 'FZ', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'FCZ', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'FT7', 'FT8', 'CZ', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
posterior_central_sites = {'CPZ', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'PZ', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POZ', 'PO3', 'PO4', 'PO7', 'PO8', 'OZ', 'O1', 'O2','PO9','PO10'};
eeg_sites = {'all', '-HEO', '-VEO'};
%%
%--------------------------------------------------------%
%
%    Before Stat. We cheak data for decide 
%                    where to find the
%                          difference.
%
%--------------------------------------------------------%
%% diff map across frontal sites
roi = fronto_central_sites;
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (Frontal-centrol Sites)';
outputfile = './figure/Interaction/diff_map_frontal';
maskfile = '';
outputfile_after_mask='';
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);

%% diff map across posterior sites
roi = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (Posterior-centrol Sites)';
outputfile = './figure/Interaction/diff_map_posterior';
maskfile = '';
outputfile_after_mask='';
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);

%% diff map across all sites
roi = '';
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (All EEG Sites)';
outputfile = './figure/Interaction/diff_map_all';
maskfile = '';
outputfile_after_mask='';
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);
%%
%--------------------------------------------------------%
%
%    After Stat. We highlight where and 
%         when the differernce show up
%
%--------------------------------------------------------%
%% prep mask file for different stat results
%    Stat comparson list
%%
% 
% # [SP_Theta] Sound Primer: Frontal, Theta
% # [SP_Beta_E1] Sound Primer: All sites, Beta Element#1
% # [SP_Beta_E2] Sound Primer: All sites, Beta Element#2
% # [VP_Alpha] Visual Probe: Posterior, Alpha
% # [VP_Beta] Visual Probe: Posterior, Beta
%

%% load mask
SP_Theta = './statMask/SP_Theta.mat';
SP_Beta = './statMask/SP_Beta.mat';
%SP_Beta_E2 = './statMask/SP_Beta.mat';
VP_Alpha = './statMask/VP_Alpha.mat';
VP_Beta = './statMask/VP_Beta.mat';

load(SP_Theta,'-mat');
load(SP_Beta,'-mat');
%load(SP_Beta_E2,'-mat');
load(VP_Alpha,'-mat');
load(VP_Beta,'-mat');

%% fronto
clear maskSets
targetTFR = diff_map;
maskSets{1} = SP_Theta;
aioMask = kb_prep_mask(maskSets,targetTFR);

% fronto-central
roi = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (Fronto-centrol Sites)';
outputfile = './figure/Interaction/diff_map_frontal';
outputfile_after_mask = './figure/statReport/stat_masked_diff_map_frontal';
maskfile = aioMask;
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);

%% posterior-central
clear maskSets
targetTFR = diff_map;
maskSets{1} = VP_Alpha;
maskSets{2} = VP_Beta;
aioMask = kb_prep_mask(maskSets,targetTFR);

% plot at posterior map
roi = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (Posterior-centrol Sites)';
outputfile = './figure/Interaction/diff_map_posterior';
outputfile_after_mask = './figure/statReport/stat_masked_diff_map_posterior';
maskfile = aioMask;
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);

%% all eeg
clear maskSets
targetTFR = diff_map;
maskSets{1} = SP_Beta;
%maskSets{2} = SP_Beta_E2;
aioMask = kb_prep_mask(maskSets,targetTFR);

% plot at all eeg
roi = {'all', '-HEO', '-VEO'};
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (All EEG Sites)';
outputfile = './figure/Interaction/diff_map_alleeg';
outputfile_after_mask = './figure/statReport/stat_masked_diff_map_alleeg';
maskfile = aioMask;
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);

%% end tf_plot
close all % close this file