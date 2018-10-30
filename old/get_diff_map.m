%%  Time-freqency analysis scritps for CNC project
% --- 01 # Followed EEG and ERP prep step; note: start para computation first
% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux server only
project_dir = pwd;% change to tfr_prep dir firsts
home_dir = fullfile(project_dir, 'data', 'TFPrep');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');

addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));
%%
%% parameter setup
fronto_central_sites = {'AF7', 'AF3', 'AF4', 'AF8', 'FZ', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'FCZ', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'FT7', 'FT8', 'CZ', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
posterior_central_sites = {'CPZ', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'PZ', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POZ', 'PO3', 'PO4', 'PO7', 'PO8', 'OZ', 'O1', 'O2','PO9','PO10'};
eeg_sites = {'all', '-HEO', '-VEO'};

%%
%% load mat
load('ProbeMultiLoud_rm.mat','-mat')
load('ProbeMultiSoft_rm.mat','-mat')
load('ProbeOneLoud_rm.mat','-mat')
load('ProbeOneSoft_rm.mat','-mat')
%% between condtion
procAction = 'diff_tf';
cfg = [];
ML_MS = loop_ana(ProbeMultiLoud_rm,procAction,cfg,ProbeMultiSoft_rm);
OL_OS = loop_ana(ProbeOneLoud_rm,procAction,cfg,ProbeOneSoft_rm);
MS_OS =  loop_ana(ProbeMultiSoft_rm,procAction,cfg,ProbeOneSoft_rm);
ML_OL = loop_ana(ProbeMultiLoud_rm,procAction,cfg,ProbeOneLoud_rm);
save ML_MS ML_MS
save OL_OS OL_OS 
save MS_OS MS_OS
save ML_OL ML_OL
%% between diff
procAction = 'diff_tf';
cfg = [];
LS_differ_under_M_O = loop_ana(ML_MS,procAction,cfg,OL_OS);
MO_diffe_under_L_S = loop_ana(ML_OL,procAction,cfg,MS_OS);

save LS_differ_under_M_O LS_differ_under_M_O
save MO_diffe_under_L_S MO_diffe_under_L_S 
%% average
%% rm no use subject's data and average them
nouse = [1,18];
ML_MS(:,nouse(1))=[];
ML_MS(:,nouse(2)-1)=[];
cfg = [];
ML_MSAVG = ft_freqgrandaverage(cfg, ML_MS{1:end});
save ML_MSAVG ML_MSAVG

OL_OS(:,nouse(1))=[];
OL_OS(:,nouse(2)-1)=[];
cfg = [];
OL_OSAVG = ft_freqgrandaverage(cfg, OL_OS{1:end});
save OL_OSAVG OL_OSAVG

MS_OS(:,nouse(1))=[];
MS_OS(:,nouse(2)-1)=[];
cfg = [];
MS_OSAVG = ft_freqgrandaverage(cfg, MS_OS{1:end});
save MS_OSAVG MS_OSAVG

ML_OL(:,nouse(1))=[];
ML_OL(:,nouse(2)-1)=[];
cfg = [];
ML_OLAVG = ft_freqgrandaverage(cfg, ML_OL{1:end});
save ML_OLAVG ML_OLAVG
%%
%% rm no use subject's data and average them
LS_differ_under_M_O(:,nouse(1))=[];
LS_differ_under_M_O(:,nouse(2)-1)=[];
cfg = [];
LS_differ_under_M_OAVG = ft_freqgrandaverage(cfg, LS_differ_under_M_O{1:end});
save LS_differ_under_M_OAVG LS_differ_under_M_OAVG

MO_diffe_under_L_S(:,nouse(1))=[];
MO_diffe_under_L_S(:,nouse(2)-1)=[];
cfg = [];
MO_diffe_under_L_SAVG = ft_freqgrandaverage(cfg, MO_diffe_under_L_S{1:end});
save MO_diffe_under_L_SAVG MO_diffe_under_L_SAVG
%% plot it
% ML_MSAVG (all)
roi = eeg_sites;
diff_map_oi = ML_MSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under Multi Sound (All EEG Sites)';
outputfile = './figure/LS_at_M_all';
maskfile = '';
outputfile_after_mask='';
crange =[-1 1];
baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ML_MSAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ML_MSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under Multi Sound  (Fronto-Central Sites)';
outputfile = './figure/LS_at_M_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ML_MSAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ML_MSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under Multi Sound (Posterior-Central Sites)';
outputfile = './figure/LS_at_M_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%% 
% OL_OSAVG (all)
roi = eeg_sites;
diff_map_oi = OL_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under One Sound (All EEG Sites)';
outputfile = './figure/LS_at_O_all';
maskfile = '';
outputfile_after_mask='';
crange =[-1 1];
baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% OL_OSAVG (fc)
roi = fronto_central_sites;
diff_map_oi = OL_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under One Sound  (Fronto-Central Sites)';
outputfile = './figure/LS_at_O_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% OL_OSAVG (pc)
roi = posterior_central_sites;
diff_map_oi = OL_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud-Soft Under One Sound (Posterior-Central Sites)';
outputfile = './figure/LS_at_O_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%% 
crange =[-0.15 0.15];
% MS_OSAVG (all)
roi = eeg_sites;
diff_map_oi = MS_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Soft Sound (All EEG Sites)';
outputfile = './figure/MO_at_S_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% MS_OSAVG (fc)
roi = fronto_central_sites;
diff_map_oi = MS_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Soft Sound  (Fronto-Central Sites)';
outputfile = './figure/MO_at_S_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% MS_OSAVG (pc)
roi = posterior_central_sites;
diff_map_oi = MS_OSAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Soft Sound (Posterior-Central Sites)';
outputfile = './figure/MO_at_S_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);
%%
crange =[-0.15 0.15];
% ML_OLAVG (all)
roi = eeg_sites;
diff_map_oi = ML_OLAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Loud Sound (All EEG Sites)';
outputfile = './figure/MO_at_L_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ML_OLAVG (fc)
roi = fronto_central_sites;
diff_map_oi = ML_OLAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Loud Sound  (Fronto-Central Sites)';
outputfile = './figure/MO_at_L_fc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% ML_OLAVG (pc)
roi = posterior_central_sites;
diff_map_oi = ML_OLAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi-One Under Loud Sound (Posterior-Central Sites)';
outputfile = './figure/MO_at_L_pc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);
%%
crange =[-0.15 0.15];
% LS_differ_under_M_OAVG (all)
roi = eeg_sites;
diff_map_oi = LS_differ_under_M_OAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud Soft Diff: Multi vs. One (All EEG Sites)';
outputfile = './figure/LS_differ_under_M_OAVG_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% LS_differ_under_M_OAVG (fc)
roi = fronto_central_sites;
diff_map_oi = LS_differ_under_M_OAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud Soft Diff: Multi vs. One  (Fronto-Central Sites)';
outputfile = './figure/LS_differ_under_M_OAVG_allfc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% LS_differ_under_M_OAVG (pc)
roi = posterior_central_sites;
diff_map_oi = LS_differ_under_M_OAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Loud Soft Diff: Multi vs. One (Posterior-Central Sites)';
outputfile = './figure/LS_differ_under_M_OAVG_allpc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

%%
crange =[-0.3 0.3];
% MO_diffe_under_L_SAVG (all)
roi = eeg_sites;
diff_map_oi = MO_diffe_under_L_SAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi One Diff: Loud vs. Soft (All EEG Sites)';
outputfile = './figure/MO_differ_under_L_SAVG_all';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% MO_diffe_under_L_SAVG (fc)
roi = fronto_central_sites;
diff_map_oi = MO_diffe_under_L_SAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi One Diff: Loud vs. Soft   (Fronto-Central Sites)';
outputfile = './figure/MO_differ_under_L_SAVG_allfc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

% MO_diffe_under_L_SAVG (pc)
roi = posterior_central_sites;
diff_map_oi = MO_diffe_under_L_SAVG;
trange = [-0.8, 0.8]; % in seconds
frange = [2, 30]; % in Hz
fig_title = 'Multi One Diff: Loud vs. Soft (Posterior-Central Sites)';
outputfile = './figure/MO_differ_under_L_SAVG_allpc';
maskfile = '';
outputfile_after_mask='';

baseline=[];
kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_title,outputfile,maskfile,outputfile_after_mask,crange,baseline);

close all