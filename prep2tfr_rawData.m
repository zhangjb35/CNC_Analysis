clear variables
clc
restoredefaultpath; %% set a clean path

% path
project_dir = pwd; % the file located
home_dir = fullfile(project_dir, 'data', 'rawEEG');
data_dir = fullfile(project_dir, 'data');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');
% toolbox
% addpath('/home/jinbo/.matlab/R2012b');
addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath([matlab_dir, filesep, 'eeglab14_1_2b']));
addpath(genpath(fuction_dir));

% located setup file from eeglab
eeglabpath = fileparts(which('eeglab')); % eeglab path
erp_setup_path = fullfile(project_dir,'setup','tfr_bdf');
%% --- 01# detect target
[subjList,namePattern] = kb_ls(fullfile(home_dir, 'sub-*', 'eeg', 'erp', 'ass_event_eeg.set')); % please remove bad subj manully first
% store path
storePath=fullfile(data_dir,'TFPrep');
mkdir(storePath)

bdfFile = kb_ls(fullfile(erp_setup_path,'bdf_*.txt'));
%% ERP
[subjList,namePattern] = kb_ls(fullfile(home_dir, 'sub-*', 'eeg', 'preprocess', 'coreog_ica_lfilt_hfilt_ref_data.set'));
for i=1:length(subjList)
    %% --- 01# load to EEGLAB
    EEG = pop_loadset('filename','coreog_ica_lfilt_hfilt_ref_data.set','filepath',fullfile(home_dir, ['sub-' sprintf('%02d',i)],'eeg','preprocess'));
    
    %% --- 02# gen event list [ERPLAB]
    EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        fullfile(storePath,['subj_' sprintf('%02d',i) 'evenLst.txt']));
    
    %% --- 03# assign bin [ERPLAB]
    for j=1:numel(bdfFile)
        EEG_epoch{j}  = pop_binlister( EEG , 'BDF', bdfFile{j}, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput',...
            'EEG' );
    end
    %% --- 04# get sync rejction of ERP analysis
    [warg, dev] = pop_kaiserbeta(0.0015);
    m = pop_firwsord('kaiser', EEG.srate, 2, dev);
    EEG_sync = pop_firws(EEG, 'fcutoff', 40, 'ftype', 'lowpass', 'wtype', 'kaiser', 'warg', warg , 'forder', m, 'minphase', 0);
    for j=1:numel(bdfFile)
        EEG_sync_epoch{j}  = pop_binlister( EEG_sync , 'BDF', bdfFile{j}, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput',...
            'EEG' );
    end
    for j=1:numel(bdfFile)
        %% --- 05# extract epoch [ERPLAB]
        EEG_epoch{j} = pop_epochbin( EEG_epoch{j} , [-2000 2000], [-200 0]);
        EEG_sync_epoch{j} = pop_epochbin( EEG_sync_epoch{j} , [-200 800], [-200 0]);
        
        %% --- 06# artifacts reject [ERPLAB]
        EEG_sync_epoch{j}   = pop_artextval( EEG_sync_epoch{j}  , 'Channel',  1:62, 'Flag', [ 1 2], 'Threshold', [ -70 70], 'Twindow', [-200 798] );
        EEG_epoch{j}.epoch( find(EEG_sync_epoch{j}.reject.rejmanual))=[];
        EEG_epoch{j}.data(:,:, find(EEG_sync_epoch{j}.reject.rejmanual))=[];
        
        %% --- 07# output to bs
        EEG_epoch{j}.setname=['sub-' sprintf('%02d',i) '_bdf_' sprintf('%02d',j)];
        pop_saveset( EEG_epoch{j}, 'filename',     EEG_epoch{j}.setname, 'filepath', storePath);
    end
    
    % clear up
    clear EEG
end