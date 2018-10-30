% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% get my tool
% addpath('/home/jinbo/.matlab/R2012b'); % for linux server only
project_dir = pwd;% change to tfr_prep dir firsts
home_dir = fullfile(project_dir, 'data', 'TFPrep');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');

addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));
% do my job
%% load mat
load('ProbeMultiLoud_rm.mat','-mat')
load('ProbeMultiSoft_rm.mat','-mat')
load('ProbeOneLoud_rm.mat','-mat')
load('ProbeOneSoft_rm.mat','-mat')
%% parameter setup
fronto_central_sites = {'AF7', 'AF3', 'AF4', 'AF8', 'FZ', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'FCZ', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'FT7', 'FT8', 'CZ', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
posterior_central_sites = {'CPZ', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'PZ', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POZ', 'PO3', 'PO4', 'PO7', 'PO8', 'OZ', 'O1', 'O2','PO9','PO10'};
eeg_sites = {'all', '-HEO', '-VEO'};
%% rm no use subject's data and average them
nouse = [1,18];
ProbeMultiLoud_rm(:,nouse(1))=[];
ProbeMultiLoud_rm(:,nouse(2)-1)=[];
cfg = [];
ProbeMultiLoud_rmAVG = ft_freqgrandaverage(cfg, ProbeMultiLoud_rm{1:end});
save ProbeMultiLoud_rmAVG ProbeMultiLoud_rmAVG

ProbeMultiSoft_rm(:,nouse(1))=[];
ProbeMultiSoft_rm(:,nouse(2)-1)=[];
cfg = [];
ProbeMultiSoft_rmAVG = ft_freqgrandaverage(cfg, ProbeMultiSoft_rm{1:end});
save multiloudAVG ProbeMultiSoft_rmAVG

ProbeOneLoud_rm(:,nouse(1))=[];
ProbeOneLoud_rm(:,nouse(2)-1)=[];
cfg = [];
ProbeOneLoud_rmAVG = ft_freqgrandaverage(cfg, ProbeOneLoud_rm{1:end});
save ProbeOneLoud_rmAVG ProbeOneLoud_rmAVG

ProbeOneSoft_rm(:,nouse(1))=[];
ProbeOneSoft_rm(:,nouse(2)-1)=[];
cfg = [];
ProbeOneSoft_rmAVG = ft_freqgrandaverage(cfg, ProbeOneSoft_rm{1:end});
save ProbeOneSoft_rmAVG ProbeOneSoft_rmAVG

%% plot it
% ProbeMultiLoud_rmAVG (all)
roi = eeg_sites;
diff_map_oi = ProbeMultiLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Loud Sound (All EEG Sites)';
outputfile = './figure/MultiLoud_condtion_all';
maskfile = '';
outputfile_after_mask='';
crange =[0.5 1.5];
baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeMultiLoud_rmAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ProbeMultiLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Loud Sound (Fronto-Central Sites)';
outputfile = './figure/MultiLoud_condtion_fc';
maskfile = '';
outputfile_after_mask='';
baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeMultiLoud_rmAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ProbeMultiLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Loud Sound (Posterior-Central Sites)';
outputfile = './figure/MultiLoud_condtion_pc';
maskfile = '';
outputfile_after_mask='';
baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%%
% ProbeMultiSoft_rmAVG
roi = eeg_sites;
diff_map_oi = ProbeMultiSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Soft Sound (All EEG Sites)';
outputfile = './figure/MultiSoft_condtion_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeMultiSoft_rmAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ProbeMultiSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Soft Sound (Fronto-Central Sites)';
outputfile = './figure/Multisoft_condtion_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeMultiSoft_rmAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ProbeMultiSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi Soft Sound (Posterior-Central Sites)';
outputfile = './figure/Multisoft_condtion_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%%
% ProbeOneLoud_rmAVG (all)
roi = eeg_sites;
diff_map_oi = ProbeOneLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Loud Sound (All EEG Sites)';
outputfile = './figure/One_Loud_condtion_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeOneLoud_rmAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ProbeOneLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Loud Sound (Fronto-Central Sites)';
outputfile = './figure/One_Loud_condtion_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeOneLoud_rmAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ProbeOneLoud_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Loud Sound (Posterior-Central Sites)';
outputfile = './figure/One_Loud_condtion_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);
%% 
% ProbeOneSoft_rmAVG (all)
roi = eeg_sites;
diff_map_oi = ProbeOneSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Soft Sound (All EEG Sites)';
outputfile = './figure/One_Soft_condtion_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeOneSoft_rmAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ProbeOneSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Soft Sound (Fronto-Central Sites)';
outputfile = './figure/One_Soft_condtion_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ProbeOneSoft_rmAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ProbeOneSoft_rmAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'One Soft Sound (Posterior-Central Sites)';
outputfile = './figure/One_Soft_condtion_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%% 
close all