%%  Time-freqency analysis scritps for CNC project
% Followed EEG and ERP prep step
% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux only
project_dir = '/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis';
home_dir = fullfile(project_dir, 'data', 'TFPrep');
matlab_dir = fullfile(project_dir, 'matlab');
fuction_dir = fullfile(project_dir, 'functions');

addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));
%close all
%% --- 02 # convert 2 fieldtrip
procAction = 'eeglab2fieldtrip';
eeglabData_cond{1} = kb_ls([home_dir filesep '*_01.set']);
eeglabData_cond{2} = kb_ls([home_dir filesep '*_02.set']);
eeglabData_cond{3} = kb_ls([home_dir filesep '*_03.set']);
eeglabData_cond{4} = kb_ls([home_dir filesep '*_04.set']);
eeglabData_cond{5} = kb_ls([home_dir filesep '*_05.set']);
cfg = [];
additoininfo = {};
parfor i=1:length(eeglabData_cond)
    fData{i} = loop_ana(eeglabData_cond{i},procAction,cfg,additoininfo);
end
%% --- 03 # timelocked analysis (Prep for induce part analysis)
procAction = 'timelocked_analysis';
cfg = [];
additoininfo = {};
parfor i=1:length(eeglabData_cond)
    tl_fData{i} = loop_ana(fData{i},procAction,cfg,additoininfo);
end
%% --- 04 # untimelocked analysis (Induce part analysis)
procAction = 'untimelocked_analysis';
cfg = [];
parfor i=1:length(eeglabData_cond)
    utl_fData{i} = loop_ana(tl_fData{i},procAction,cfg,fData{i});
end
save utl_fData utl_fData -v7.3
%% --- 05 # transformed to Time-Freqency
procAction = 'time_frequency_representation';
%for high freq (>30Hz)

% cfg = [];
% cfg.method = 'wavelet';
% cfg.width = 4; %% width of wavelet
% cfg.output = 'pow';
% % cfg.method = 'mtmconvol';
% cfg.foi = 2:1:30; %% frequency limits (Hz)
% cfg.toi = -1.500:0.01:1.500; %% times of interest (s)
% cfg.pad = 'nextpow2';

% for low freq (<30Hz)
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.foi          = 2:0.5:30;
cfg.t_ftimwin    = 4./cfg.foi;  % 4 cycles per time window
cfg.toi          = -1.5:0.01:1.5;
parfor i=1:length(eeglabData_cond)
    tfr_utl_fData{i} = loop_ana(utl_fData{i},procAction,cfg,{});
end
% save tfr results
save tfr_utl_fData tfr_utl_fData -v7.3

%% --- 06 # (No) based tfr on no sound condition for statistical comparsion
clear *_fData
load tfr_utl_fData.mat
noSound_baseline = tfr_utl_fData{1};
ProbeMultiSoft =  tfr_utl_fData{2};
ProbeMultiLoud =  tfr_utl_fData{3};
ProbeOneSoft =  tfr_utl_fData{4};
ProbeOneLoud =  tfr_utl_fData{5};
cfg = [];
procAction = 'cond_baseline_ref';
ProbeMultiSoft_refBaseline = loop_ana(ProbeMultiSoft,procAction,cfg,noSound_baseline);
ProbeMultiLoud_refBaseline = loop_ana(ProbeMultiLoud,procAction,cfg,noSound_baseline);
ProbeOneSoft_refBaseline = loop_ana(ProbeOneSoft,procAction,cfg,noSound_baseline);
ProbeOneLoud_refBaseline = loop_ana(ProbeOneLoud,procAction,cfg,noSound_baseline);
%% --- 07 # compute the grand average for conditions
% cfg = [];
% nosoundAVG = ft_freqgrandaverage(cfg, tfr_utl_fData{1}{1:end});
% save nosoundAVG nosoundAVG

cfg = [];
multisoftAVG = ft_freqgrandaverage(cfg,ProbeMultiSoft_refBaseline{1:end});
save multisoftAVG multisoftAVG

cfg = [];
multiloudAVG = ft_freqgrandaverage(cfg, ProbeMultiLoud_refBaseline{1:end});
save multiloudAVG multiloudAVG

cfg = [];
onesoftAVG = ft_freqgrandaverage(cfg, ProbeOneSoft_refBaseline{1:end});
save onesoftAVG onesoftAVG

cfg = [];
oneloudAVG = ft_freqgrandaverage(cfg, ProbeOneLoud_refBaseline{1:end});
save oneloudAVG oneloudAVG

%% --- 08 # clustering statistcal analysis
% interaction between sound numeristy and sound magnitute
%%%%%%%%%%%%%%%%%%%%%
% prep data
procAction = 'diff_tf';
cfg = [];
MS_ML = loop_ana(ProbeMultiLoud_refBaseline,procAction,cfg,ProbeMultiSoft_refBaseline); % ML - MS
OS_OL = loop_ana(ProbeOneLoud_refBaseline,procAction,cfg,ProbeOneSoft_refBaseline); % OL - OS
save MS_ML MS_ML
save OS_OL OS_OL 

MS_OS = loop_ana(ProbeMultiSoft_refBaseline,procAction,cfg,ProbeOneSoft_refBaseline); % MS - OS
ML_OL = loop_ana(ProbeMultiLoud_refBaseline,procAction,cfg,ProbeOneLoud_refBaseline); % ML - OL
save MS_OS MS_OS
save ML_OL ML_OL
%%%%%%%%%%%%%%%%%%%%%
% prepare_neighbours determines with what sensors the planar gradient is computed
load MS_ML
load OS_OL
load ML_OL
load MS_OS
%% sound, theta 4-6, -400 - -200, frontal-central
cfg = [];
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
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

%cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
%cfg.channel = {'all', '-HEO', '-VEO'};
cfg.latency          = [-0.4 -0.2];
cfg.frequency        = [4 6];
%cfg.avgoverfreq = 'no';
%cfg.avgovertime = 'no';
cfg.avgoverchan = 'yes';

cfg.correctm         = 'cluster';

cfg.design = [
repmat(1:1:size(MS_ML,2), 1, 2) % subject number
ones(1,size(MS_ML,2)), 2*ones(1,size(OS_OL,2))];  % condition number

cfg.uvar = 1;                                   % "subject" is unit of observation
cfg.ivar = 2;                                   % "condition" is the dependent variable

stat_interaction_theta_sound_focus_sound = ft_freqstatistics(cfg, MS_ML{1:end}, OS_OL{1:end});
save stat_interaction_theta_sound_focus_sound stat_interaction_theta_sound_focus_sound -v7.3
stat_interaction_theta_sound_focus_numer = ft_freqstatistics(cfg, MS_OS{1:end}, ML_OL{1:end});
save stat_interaction_theta_sound_focus_numer stat_interaction_theta_sound_focus_numer -v7.3

%% sound, beta1 12-18, -450 - 0ms, frontal-central
cfg = [];
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
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

%cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
%cfg.channel = {'all', '-HEO', '-VEO'};
cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
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
%%
%% probe, alpha1 8-9, 0 - 350ms, postior-central
cfg = [];
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
%cfg.minnbchan        = 0;

cfg.tail             = -1;
cfg.clustertail      = -1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
%cfg.channel = {'all', '-HEO', '-VEO'};
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
%%
%% probe, beta 12-25, 50 - 250ms, postior-central
cfg = [];
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
%cfg.minnbchan        = 0;

cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;

cfg.numrandomization = 10000;

%cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
%cfg.channel = {'all', '-HEO', '-VEO'};
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

