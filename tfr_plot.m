%% prep data, toolbox, and functions
% zero the world
clear, clc
restoredefaultpath; %% set a clean path

% load and prep data
load('./data/effectAVG/MS_MLAVG.mat','-mat');
load('./data/effectAVG/OS_OLAVG.mat','-mat'); 
temp = MS_MLAVG;
temp.powspctrm =  temp.powspctrm - OS_OLAVG.powspctrm;
diff_map = temp;
clear temp

% toolbox
home_dir = '/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis';
toolbox_dir = fullfile(home_dir, 'toolbox');
fuction_dir = fullfile(home_dir, 'functions');
addpath(fullfile(toolbox_dir, 'fieldtrip-20180922')); ft_defaults;
addpath(genpath(fullfile(toolbox_dir, 'eeglab14_1_2b')));

% function
addpath(genpath(fuction_dir));
%%
%--------------------------------------------------------%
%
%    Before Stat. We cheak data for decide 
%                    where to find the
%                          difference.
%
%--------------------------------------------------------%
%% diff map across frontal sites
roi = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
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
% # [SP_F_Theta] Sound Primer: Frontal, Theta
% # [SP_Beta_E1] Sound Primer: All sites, Beta Element#1
% # [SP_Beta_E2] Sound Primer: All sites, Beta Element#2
% # [VP_Alpha] Visual Probe: Posterior, Alpha
% # [VP_Beta] Visual Probe: Posterior, Beta
%

%% load mask
VP_Alpha = './statMask/VP_Alpha.mat';
load(VP_Alpha,'-mat');

%% Synthetic mask
targetTFR = diff_map;
maskSets{1} = stat_interaction_alpha;
maskSets{2} = stat_interaction_alpha;
aioMask = kb_prep_mask(maskSets,targetTFR);

%% Plot at posterior map
%% diff map across posterior sites
roi = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
diff_map_oi = diff_map;
trange = [-0.8, 0.8]; % in seconds
frange = [4, 30]; % in Hz
fig_title = 'Interaction Effect (Posterior-centrol Sites)';
outputfile = './figure/Interaction/diff_map_posterior';
outputfile_after_mask = './figure/statReport/stat_masked_diff_map_posterior';
maskfile = aioMask;
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask);