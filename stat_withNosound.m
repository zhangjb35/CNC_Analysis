%%  Stat about Time-freqency analysis
% Followed TFR
% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux only
project_dir = '/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis';
home_dir = fullfile(project_dir, 'data', 'TFPrep');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');

addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));

% setup common information
fronto_central_sites = {'AF7', 'AF3', 'AF4', 'AF8', 'FZ', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'FCZ', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'FT7', 'FT8', 'CZ', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
posterior_central_sites = {'CPZ', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'PZ', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POZ', 'PO3', 'PO4', 'PO7', 'PO8', 'OZ', 'O1', 'O2','PO9','PO10'};
eeg_sites = {'all', '-HEO', '-VEO'};
%% load data
targetData = kb_ls(fullfile(project_dir,'data','conditionRaw','*.mat'));
cellfun(@load,targetData);

%% multi loud vs no sound
cfg = [];
%do need explore at sites level, skip it
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = './setup/cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, noSound_baseline{1});
%cfg.neighbourdist    = 2;
%cfg.neighbours = [];
%setup stat parameter

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0; % across chnnel so skip it

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 10000;

cfg.channel          = eeg_sites;
%cfg.channel = eeg_sites;
cfg.latency          = [-0.5 0.8];
cfg.frequency        = [2 30];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
%cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(noSound_baseline,2), 1, 2) % subject number (how many subject use to observe the effect)
ones(1,size(noSound_baseline,2)), 2*ones(1,size(ProbeMultiLoud,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

ML_Control_stat = ft_freqstatistics(cfg, ProbeMultiLoud{1:end}, noSound_baseline{1:end});
save ML_Control_stat ML_Control_stat -v7.3

%% multi soft vs no sound
cfg = [];
%do need explore at sites level, skip it
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = './setup/cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, noSound_baseline{1});
%cfg.neighbourdist    = 2;
%cfg.neighbours = [];
%setup stat parameter

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0; % across chnnel so skip it

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 10000;

cfg.channel          = eeg_sites;
%cfg.channel = eeg_sites;
cfg.latency          = [-0.5 0.8];
cfg.frequency        = [2 30];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
%cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(noSound_baseline,2), 1, 2) % subject number (how many subject use to observe the effect)
ones(1,size(noSound_baseline,2)), 2*ones(1,size(ProbeMultiSoft,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

MS_Control_stat = ft_freqstatistics(cfg, ProbeMultiSoft{1:end}, noSound_baseline{1:end});
save MS_Control_stat MS_Control_stat -v7.3

%% one loud vs no sound
cfg = [];
%do need explore at sites level, skip it
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = './setup/cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, noSound_baseline{1});
%cfg.neighbourdist    = 2;
%cfg.neighbours = [];
%setup stat parameter

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0; % across chnnel so skip it

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 10000;

cfg.channel          = eeg_sites;
%cfg.channel = eeg_sites;
cfg.latency          = [-0.5 0.8];
cfg.frequency        = [2 30];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
%cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(noSound_baseline,2), 1, 2) % subject number (how many subject use to observe the effect)
ones(1,size(noSound_baseline,2)), 2*ones(1,size(ProbeOneLoud,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

OL_Control_stat = ft_freqstatistics(cfg, ProbeMultiSoft{1:end}, noSound_baseline{1:end});
save OL_Control_stat OL_Control_stat -v7.3

%% one soft vs no sound
cfg = [];
%do need explore at sites level, skip it
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = './setup/cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, noSound_baseline{1});
%cfg.neighbourdist    = 2;
%cfg.neighbours = [];
%setup stat parameter

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0; % across chnnel so skip it

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 10000;

cfg.channel          = eeg_sites;
%cfg.channel = eeg_sites;
cfg.latency          = [-0.5 0.8];
cfg.frequency        = [2 30];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
%cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(noSound_baseline,2), 1, 2) % subject number (how many subject use to observe the effect)
ones(1,size(noSound_baseline,2)), 2*ones(1,size(ProbeOneSoft,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

OS_Control_stat = ft_freqstatistics(cfg, ProbeOneSoft{1:end}, noSound_baseline{1:end});
save OS_Control_stat OS_Control_stat -v7.3