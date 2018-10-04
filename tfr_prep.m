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

%% --- 02 # convert eeglab data to fieldtrip format
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

%% --- 03 # calcuate ERP
procAction = 'timelocked_analysis';
cfg = [];
additoininfo = {};
parfor i=1:length(eeglabData_cond)
    tl_fData{i} = loop_ana(fData{i},procAction,cfg,additoininfo);
end

%% --- 04 # remove ERP from each trial for extracting pure induced part of EEG activity
procAction = 'untimelocked_analysis';
cfg = [];
parfor i=1:length(eeglabData_cond)
    utl_fData{i} = loop_ana(tl_fData{i},procAction,cfg,fData{i});
end
save utl_fData utl_fData -v7.3

%% --- 05 # transformed to Time-Freqency domain
procAction = 'time_frequency_representation';

%for high freq (>30Hz), so we do not use this method, see fieldtrip
%tutorial

% cfg = [];
% cfg.method = 'wavelet';
% cfg.width = 4; %% width of wavelet
% cfg.output = 'pow';
% % cfg.method = 'mtmconvol';
% cfg.foi = 2:1:30; %% frequency limits (Hz)
% cfg.toi = -1.500:0.01:1.500; %% times of interest (s)
% cfg.pad = 'nextpow2';

% we foi is low freq part (<30Hz)
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.foi          = 2:0.5:30; % in Hz
cfg.t_ftimwin    = 4./cfg.foi;  % 4 cycles per time window
cfg.toi          = -1.5:0.01:1.5; % in second

parfor i=1:length(eeglabData_cond)
    tfr_utl_fData{i} = loop_ana(utl_fData{i},procAction,cfg,{});
end
% save tfr results
save tfr_utl_fData tfr_utl_fData -v7.3

%% --- 06 # baseline on no sound condition, so we do not need to do time baseline : )
clear *_fData % release memory for followd "very computer consuming" computation
load tfr_utl_fData.mat
noSound_baseline = tfr_utl_fData{1};
ProbeMultiSoft =  tfr_utl_fData{2};
ProbeMultiLoud =  tfr_utl_fData{3};
ProbeOneSoft =  tfr_utl_fData{4};
ProbeOneLoud =  tfr_utl_fData{5};% this correspondence checked with bdf file, see setup folder
cfg = [];
procAction = 'cond_baseline_ref';
ProbeMultiSoft_refBaseline = loop_ana(ProbeMultiSoft,procAction,cfg,noSound_baseline);
ProbeMultiLoud_refBaseline = loop_ana(ProbeMultiLoud,procAction,cfg,noSound_baseline);
ProbeOneSoft_refBaseline = loop_ana(ProbeOneSoft,procAction,cfg,noSound_baseline);
ProbeOneLoud_refBaseline = loop_ana(ProbeOneLoud,procAction,cfg,noSound_baseline);
%% --- 07 # average TFR across subject for plot TFR prep for stat and after stat resutls visualization)
% as baseline, skip it

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

%% --- 08 # prep for interaction part of experimental effect 
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

% --- 09 # main effect, check interaction first, if sign, skip it. If interaction, it is no reason to see main effect (depend on another variable)