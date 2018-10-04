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
% # Sound, theta 4-6, -400 - -200, frontal-central
% # Sound, Beta_EL#1 4-6, -400 - -200, eeg_sites
% # Sound, Beta_EL#2 4-6, -400 - -200, eeg_sites
% # Probe, Alpha 8-9, 0 - 350, postior-central
% # Probe, Beta 12-25, 50 - 250, postior-central
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

stat_interaction_theta_sound_focus_sound = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save stat_interaction_theta_sound_focus_sound stat_interaction_theta_sound_focus_sound -v7.3
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

stat_interaction_sound_beta = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save stat_interaction_sound_beta stat_interaction_sound_beta -v7.3
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
save stat_interaction_sound_beta stat_interaction_sound_beta -v7.3
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

stat_interaction_alpha = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save stat_interaction_alpha stat_interaction_alpha -v7.3

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

stat_interaction_beta_point = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save stat_interaction_beta_point stat_interaction_beta_point -v7.3
%%
% %% probe, theta 4-8, 400 - 800ms, postior-central
% cfg = [];
% cfg_neighb.method    = 'distance';
% cfg_neighb.layout    = 'cnc_eeg.mat';
% cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
% cfg.neighbourdist    = 8;
% cfg.neighbours = [];
% %setup stat parameter
% cfg.method           = 'montecarlo';
% cfg.statistic        = 'depsamplesT';
% cfg.clusteralpha     = 0.05;
% cfg.clusterstatistic = 'maxsum';
% %cfg.minnbchan        = 0;
% 
% cfg.tail             = 0;
% cfg.clustertail      = 0;
% cfg.alpha            = 0.025;
% 
% cfg.numrandomization = 300;
% 
% %cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
% %cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
% cfg.channel = {'all', '-HEO', '-VEO'};
% cfg.latency          = [0.4 0.8];
% cfg.frequency        = [4 10];
% %cfg.avgoverfreq = 'no';
% %cfg.avgovertime = 'no';
% %cfg.avgoverchan = 'yes';
% 
% cfg.correctm         = 'cluster';
% 
% cfg.design = [
% repmat(1:1:size(MS_ML,2), 1, 2) % subject number
% ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number
% 
% cfg.uvar = 1;                                   % "subject" is unit of observation
% cfg.ivar = 2;                                   % "condition" is the dependent variable
% 
% stat_interaction_alpha_end = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
% save stat_interaction_alpha_end stat_interaction_alpha_end -v7.3
%%
% 
% %% theta post -500--100ms; 4-6Hz
% cfg = [];
% cfg_neighb.method    = 'distance';
% cfg_neighb.layout    = 'cnc_eeg.mat';
% cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, MS_ML{1});
% cfg.neighbourdist    = 4;
% % setup stat parameter
% cfg.method           = 'montecarlo';
% cfg.statistic        = 'depsamplesT';
% cfg.clusteralpha     = 0.05;
% cfg.clusterstatistic = 'maxsum';
% cfg.minnbchan        = 2;
% 
% cfg.tail             = 0;
% cfg.clustertail      = 0;
% cfg.alpha            = 0.05;
% 
% cfg.numrandomization = 5000;
% 
% %cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
% cfg.channel = {'all', '-HEO', '-VEO'};
% cfg.latency          = [-0.5 0];
% cfg.frequency        = [4 6];
% cfg.avgoverfreq = 'yes';
% cfg.avgovertime = 'yes';
% cfg.correctm         = 'cluster';
% 
% cfg.design = [
% repmat(1:1:size(MS_ML,2), 1, 2) % subject number
% ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number
% 
% cfg.uvar = 1;                                   % "subject" is unit of observation
% cfg.ivar = 2;                                   % "condition" is the dependent variable
% 
% stat_interaction_simple_mag_theta = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
% save stat_interaction_simple_mag_theta stat_interaction_simple_mag_theta -v7.3
% stat_interaction_simple_num_theta = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
% save stat_interaction_simple_num_theta stat_interaction_simple_num_theta -v7.3
% %%
% cfg = []
% cfg.marker = 'on'
% cfg.layout = 'cnc_eeg.mat'
% cfg.channel = {'all', '-HEO', '-VEO'}
% cfg.parameter = 'prob';
% cfg.maskparameter = 'mask'
% cfg.maskstyle = 'opacity';
% figure; ft_multiplotTFR(cfg, stat_interaction_simple_mag_alpha)
%%
cfg = []
cfg.alpha = .05
cfg.layout = 'cnc_eeg.mat'
ft_clusterplot(cfg,stat_interaction_simple_mag_theta)
% main effect of sound numeristy
%%%%%%%%%%%%%%%%%%%%%
% prep data
procAction = 'average_tf';
cfg = [];
M = loop_ana(ProbeMultiLoud_refBaseline,procAction,cfg,ProbeMultiSoft_refBaseline); % avg(ML + MS)=M
O = loop_ana(ProbeOneLoud_refBaseline,procAction,cfg,ProbeOneSoft_refBaseline); % avg(OL + OS)=O
save M M
save O O
%%%%%%%%%%%%%%%%%%%%%
% prepare_neighbours determines with what sensors the planar gradient is computed
load M
load O
cfg = [];
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = 'cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, M{1});
cfg.neighbourdist    = 4;

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 5000;

cfg.channel          = 'eeg';
cfg.latency          = [-0.2 0.8];
cfg.frequency        = [5 30];

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(M,2), 1, 2) % subject number
[ones(1,size(M,2)), 2*ones(1,size(O,2))]];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

stat_main_numersity = ft_freqstatistics(cfg, M{1:end}, O{1:end});
save stat_main_numersity stat_main_numersity -v7.3
% main effect of sound magnitute
%%%%%%%%%%%%%%%%%%%%%
% prep data
procAction = 'average_tf';
cfg = [];
L = loop_ana(ProbeMultiLoud_refBaseline,procAction,cfg,ProbeOneLoud_refBaseline); % avg(ML + OL)=L
S = loop_ana(ProbeMultiSoft_refBaseline,procAction,cfg,ProbeOneSoft_refBaseline); % avg(MS + OS)=S
save L L
save S S
%%%%%%%%%%%%%%%%%%%%%
% prepare_neighbours determines with what sensors the planar gradient is computed
load L
load S
cfg = [];
cfg_neighb.method    = 'distance';
cfg_neighb.layout    = 'cnc_eeg.mat';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, L{1});
cfg.neighbourdist    = 4;

cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;

cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

cfg.numrandomization = 5000;

cfg.channel          = 'eeg';
cfg.latency          = [-0.2 0.8];
cfg.frequency        = [5 30];

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(L,2), 1, 2) % subject number
ones(1,size(L,2)), 2*ones(1,size(S,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

stat_main_magnitute = ft_freqstatistics(cfg, L{1:end}, S{1:end});
save stat_main_magnitute stat_main_magnitute -v7.3
% %% see
% % multi freq
% cfg               = [];
% cfg.marker        = 'on';
% cfg.layout        = 'cnc_eeg.mat';
% cfg.channel       = 'eeg';
% cfg.xlim = [-0.2 0.8];
% % cfg.yim = [5 30];
% cfg.parameter     = 'stat';  % plot the t-value 
% cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
% cfg.maskstyle     = 'saturation';
% cfg.alpha  = 0.10;
% ft_multiplotTFR(cfg, stat_main_magnitute);