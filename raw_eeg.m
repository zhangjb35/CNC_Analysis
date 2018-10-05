clear variables
clc
restoredefaultpath; %% set a clean path

% path
project_dir = pwd; % the file located
home_dir = fullfile(project_dir, 'data', 'rawEEG');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');
% toolbox
% addpath('/home/jinbo/.matlab/R2012b');
addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));

% located setup file from eeglab
eeglabpath = fileparts(which('eeglab')); % eeglab path

%% Preprocess
[subjList,namePattern] = kb_ls(fullfile(home_dir,'sub-*','eeg','*.set'));
for i=2:length(subjList)
    %% --- 01# prepare path
    % setup store path
    storePath=fullfile(home_dir,['sub-' sprintf('%02d',i)],'eeg','preprocess');
    mkdir(storePath);
    %% --- 02# load to EEGLAB
    EEG = pop_loadset('filename',['sub-' sprintf('%02d',i) '_task-psychophysics_eeg.set'],'filepath',fullfile([filesep namePattern,sprintf('%02d',i)],'eeg'));
    
    %% --- 03# remove empty channel
    EEG = pop_select( EEG,'nochannel',{'M1' 'EKG' 'EMG'});
    
    %% --- 04# load location
    EEG=pop_chanedit(EEG, 'lookup',...
        [eeglabpath '' filesep 'plugins' filesep 'dipfit2.3' filesep 'standard_BESA' filesep 'standard-10-5-cap385.elp'],...
        'changefield',{63 'labels' 'AF8'},'changefield',{59 'labels' 'AF7'},...
        'changefield',{57 'labels' 'PO10'},'changefield',{53 'labels' 'PO9'},'lookup',...
        [eeglabpath '' filesep 'plugins' filesep 'dipfit2.3' filesep 'standard_BESA' filesep 'standard-10-5-cap385.elp']);
    EEG.setname='origin_data';
    
    %% --- 05# calc semi M2 with erplab
    EEG = pop_eegchanoperator( EEG,...
        { 'ch66 = ch42/2.0 label semiM2'} , ...
        'ErrorMsg', 'popup', 'Warning', 'off' );
    
    %% --- 06# re-ref
    EEG = pop_reref( EEG, 66,'exclude',[64 65] );
    
    %% --- 07# remove m2 from dataset
    EEG = pop_select( EEG,'nochannel',{'M2'});
    EEG.setname='ref_data';
    
    %% --- 08# high pass filter .5 Hz
    [warg, dev] = pop_kaiserbeta(0.0015);
    m = pop_firwsord('kaiser', EEG.srate, 2, dev);
    EEG = pop_firws(EEG, 'fcutoff', 0.5, 'ftype', 'highpass', 'wtype', 'kaiser', 'warg', warg , 'forder', m, 'minphase', 0);
    EEG.setname='hfilt_ref_data';
    
    %% --- 09# run ICA on continue data and correct EOG
    % save data
    EEG = pop_runica(EEG, 'icatype','runica','chanind',1:62);
    EEG.setname='ica_lfilt_hfilt_ref_data';
    pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
    
    %% --- 10# correct eog
    % save data
    load(fullfile(fuction_dir, 'saica_cfg.mat'),'-mat')
    [EEG_temp, ~] = eeg_SASICA(EEG,varargin{1,1});
    rmIndex = find(EEG_temp.reject.gcompreject>0);
    
    if ~isempty(rmIndex)
        EEG = pop_subcomp( EEG_temp, rmIndex, 0);
        clear EEG_temp
        EEG.setname='coreog_ica_lfilt_hfilt_ref_data';
        pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
    else
        clear EEG_temp
        clear varargin
        load(fullfile(fuction_dir,'saica_cfg_adjust.mat','-mat');
        [EEG_temp, ~] = eeg_SASICA(EEG,varargin{1,1});
        rmIndex = find(EEG_temp.reject.gcompreject>0);
        if isempty(rmIndex)
            clear EEG_temp
            EEG.setname='failed_coreog_ica_lfilt_hfilt_ref_data';
            pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
        else
            EEG = pop_subcomp( EEG_temp, rmIndex, 0);
            clear EEG_temp
            EEG.setname='coreog_ica_lfilt_hfilt_ref_data';
            pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
        end
    end
    clear EEG
end