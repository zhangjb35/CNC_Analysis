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
fronto_central_sites = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
posterior_central_sites = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
eeg_sites = {'all', '-HEO', '-VEO'};

%% --- #01 load interaction effect part
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Interaction= Loud (B1) minus Soft (B2) under Multi (A1) and One sound
% condition (A2)
% MS_ML, OS_OL level = M minus O
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
load MS_ML
load OS_OL
% load ML_OL % same resutls, the diff of those two is same as first two.
% load MS_OS

%% --- #02 Decide what time, freq and sites to examine condition difference
%%
% 
% # Sound, theta 4-6, -400 - -200, frontal-central, save as SP_Theta.mat
% # Sound, Beta_EL#1 4-6, -400 - -200, eeg_sites, save as SP_Beta_E1.mat
% # Sound, Beta_EL#2 4-6, -400 - -200, eeg_sites, save as SP_Beta_E2.mat
% # Probe, Alpha 8-9, 0 - 350, postior-central, VP_Alpha.mat
% # Probe, Beta 12-25, 50 - 250, postior-central, VP_Beta.mat
%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Sound, theta 4-6, -400 - -200, frontal-central
%
%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg = [];
% do need explore at sites level, skip it
%cfg_neighb.method    = 'distance';
%cfg_neighb.layout    = 'cnc_eeg.mat';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
%cfg.neighbourdist    = 8;
%cfg.neighbours = [];
%setup stat parameter

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0; % across chnnel so skip it

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel          = fronto_central_sites;

cfg.latency          = [-0.4 -0.2];
cfg.frequency        = [4 6];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number (how many subject use to observe the effect)
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

SP_Theta = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save SP_Theta SP_Theta -v7.3
% stat_interaction_theta_sound_focus_numer = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
% save stat_interaction_theta_sound_focus_numer stat_interaction_theta_sound_focus_numer -v7.3


%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Sound, Beta_EL#1 4-6, -400 - -200, eeg_sites
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];

%cfg_neighb.method    = 'distance';
%cfg_neighb.layout    = 'cnc_eeg.mat';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
%cfg.neighbourdist    = 8;
%cfg.neighbours = [];

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel = eeg_sites;

cfg.latency          = [-0.45 0];
cfg.frequency        = [12 18];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

SP_Beta_E1 = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save SP_Beta_E1 SP_Beta_E1 -v7.3
% stat_interaction_simple_num_alpha = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
% save stat_interaction_simple_num_alpha stat_interaction_simple_num_alpha -v7.3

%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Sound, Beta_EL#2 4-6, -400 - -200, eeg_sites
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];

%cfg_neighb.method    = 'distance';
%cfg_neighb.layout    = 'cnc_eeg.mat';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
%cfg.neighbourdist    = 8;
%cfg.neighbours = [];

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel = eeg_sites;

cfg.latency          = [-0.45 0];
cfg.frequency        = [12 18];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

stat_interaction_sound_beta = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save SP_Beta_E2 SP_Beta_E2 -v7.3
% stat_interaction_simple_num_alpha = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
% save stat_interaction_simple_num_alpha stat_interaction_simple_num_alpha -v7.3

%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Probe, Alpha 8-9, 0 - 350, postior-central
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];

%cfg_neighb.method    = 'distance';
%cfg_neighb.layout    = 'cnc_eeg.mat';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
%cfg.neighbourdist    = 8;
%cfg.neighbours = [];

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0;

cfg.tail             = -1;
cfg.clustertail      = -1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel          = posterior_central_sites;

cfg.latency          = [0 0.35];
cfg.frequency        = [6 10];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

VP_Alpha = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save VP_Alpha VP_Alpha -v7.3

%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Probe, Beta 12-25, 50 - 250, postior-central
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];

%cfg_neighb.method    = 'distance';
%cfg_neighb.layout    = 'cnc_eeg.mat';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
%cfg.neighbourdist    = 8;
%cfg.neighbours = [];

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel          = posterior_central_sites;

cfg.latency          = [0.05 0.25];
cfg.frequency        = [12 25];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

VP_Beta = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save VP_Beta VP_Beta -v7.3