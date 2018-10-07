% SET PATHS
clear variables
restoredefaultpath; %% set a clean path

home_dir = pwd;
matlab_dir = fullfile(home_dir, 'toolbox'); % change according to your path
fuction_dir = fullfile(home_dir, 'functions');
data_dir = fullfile(home_dir, '/data/rawEEG');

erp_setup_path = fullfile(home_dir,'/setup');

% ADD PATHS

% add your toolbox
% addpath('/home/jinbo/.matlab/R2012b'); % for linux only
addpath(fullfile(matlab_dir, 'fieldtrip-20180922')); ft_defaults %% initialize FieldTrip defaults
addpath(genpath(fullfile(matlab_dir, 'eeglab14_1_2b')));
eeglabpath = fileparts(which('eeglab')); % eeglab path
addpath(genpath(fuction_dir));

bdfFile_sp = fullfile(erp_setup_path,'bdf_sp.txt');
bdfFile_vp = fullfile(erp_setup_path,'bdf_vp.txt');
%% ERP
[subjList,namePattern] = kb_ls(fullfile(data_dir, 'sub-*', 'eeg', 'preprocess', 'coreog_ica_lfilt_hfilt_ref_data.set'));
for i=8:length(subjList)
    %% --- 01# prepare path
    % setup store path
    storePath=fullfile(home_dir,'data','rawEEG',['sub-' sprintf('%02d',i)],'eeg','erp_70uv_threshodl');
    mkdir(storePath);
    %% --- 02# load to EEGLAB
    EEG = pop_loadset('filename','coreog_ica_lfilt_hfilt_ref_data.set','filepath',fullfile(home_dir,'data','rawEEG',['sub-' sprintf('%02d',i)],'eeg','preprocess'));
    
    %% --- 03# low pass filter 40 Hz
    [warg, dev] = pop_kaiserbeta(0.0015);
    m = pop_firwsord('kaiser', EEG.srate, 2, dev);
    EEG = pop_firws(EEG, 'fcutoff', 40, 'ftype', 'lowpass', 'wtype', 'kaiser', 'warg', warg , 'forder', m, 'minphase', 0);
    EEG.setname='eeg';
    
    %% --- 04# gen event list [ERPLAB]
    EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        fullfile(storePath,'evenLst.txt'));
    EEG.setname = 'event_eeg';
    
    %% --- 05# assign bin [ERPLAB]
    % sp
    EEG_sp  = pop_binlister( EEG , 'BDF', bdfFile_sp, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput',...
        'EEG' );
    EEG_sp.setname='ass_event_eeg_sp';
    pop_saveset(EEG_sp, 'filename', EEG_sp.setname, 'filepath', storePath);
    % vp
    EEG_vp  = pop_binlister( EEG , 'BDF', bdfFile_vp, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput',...
        'EEG' );
    EEG_vp.setname='ass_event_eeg_vp';
    pop_saveset(EEG_vp, 'filename', EEG_vp.setname, 'filepath', storePath);
    %% --- 06# extract epoch [ERPLAB]
    % sp
    EEG_sp = pop_epochbin( EEG_sp , [-200 3000], [-200 0]);
    EEG_sp.setname='epoch_ass_event_eeg_sp';
    pop_saveset(EEG_sp, 'filename', EEG_sp.setname, 'filepath', storePath);
    % vp
    EEG_vp = pop_epochbin( EEG_vp , [-700 2500], [-200 0]);
    EEG_vp.setname='epoch_ass_event_eeg_vp';
    pop_saveset(EEG_vp, 'filename', EEG_vp.setname, 'filepath', storePath);
    %% --- 07# artifacts reject [ERPLAB]
    % sp
    EEG_sp  = pop_artextval( EEG_sp , 'Channel',  1:62, 'Flag', [ 1 2], 'Threshold', [ -70 70], 'Twindow', [-200 500] );
    EEG_sp.setname='artifact_epoch_ass_event_eeg_sp';
    EEG_sp = pop_summary_AR_eeg_detection(EEG_sp, fullfile(storePath, [EEG_sp.setname, '.txt']));
    pop_saveset(EEG_sp, 'filename', EEG_sp.setname, 'filepath', storePath);
    
    % vp
    EEG_vp  = pop_artextval( EEG_vp , 'Channel',  1:62, 'Flag', [ 1 2], 'Threshold', [ -70 70], 'Twindow', [-200 798] );
    EEG_vp.setname='artifact_epoch_ass_event_eeg_vp';
    EEG_vp = pop_summary_AR_eeg_detection(EEG_vp, fullfile(storePath, [EEG_vp.setname, '.txt']));
    pop_saveset(EEG_vp, 'filename', EEG_vp.setname, 'filepath', storePath);
    
    %% --- 08# average [ERPLAB]
    ERP_sp = pop_averager( EEG_sp , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP_vp = pop_averager( EEG_vp , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    %% --- 09# save ERP [ERPLAB]
    ERP_sp = pop_savemyerp(ERP_sp, 'erpname',...
        ['sub-' sprintf('%02d',i)], 'filename',  ['sub-' sprintf('%02d',i) '_sp.erp'], 'filepath',storePath, 'Warning', 'off');
    ERP_vp = pop_savemyerp(ERP_vp, 'erpname',...
        ['sub-' sprintf('%02d',i)], 'filename',  ['sub-' sprintf('%02d',i) '_vp.erp'], 'filepath',storePath, 'Warning', 'off');
    % clear up
    clear EEG
end
%% --- 10# grand avage  [ERPLAB]
%% sp
% get individual subject erp file list
all_ERP_sp = kb_ls(fullfile(data_dir, 'sub-*', 'eeg', 'erp_70uv_threshodl', '*_sp.erp'));
dlmcell( 'grandAVG_list_sp.txt',all_ERP_sp);
movefile('grandAVG_list_sp.txt',[home_dir, filesep, 'ERP']);
% grand average and save grand erp
ERP_weight_sp = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list_sp.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'on');
pop_savemyerp(ERP_weight_sp, 'erpname',...
       'grand_avg_weight_sp', 'filename', 'grand_avg_weight_sp.erp', 'filepath',fullfile(home_dir, 'ERP') , 'Warning', 'off');
   
ERP_noweigth_sp = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list_sp.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'off' );
pop_savemyerp(ERP_noweigth_sp, 'erpname',...
       'grand_avg_noweight_sp', 'filename', 'grand_avg_noweight_sp.erp', 'filepath',fullfile(home_dir, 'ERP') , 'Warning', 'off');
   
%% vp
% get individual subject erp file list
all_ERP_vp = kb_ls(fullfile(data_dir, 'sub-*', 'eeg', 'erp_70uv_threshodl', '*_vp.erp'));
dlmcell( 'grandAVG_list_vp.txt',all_ERP_vp);
movefile('grandAVG_list_vp.txt',[home_dir, filesep, 'ERP']);
% grand average and save grand erp
ERP_weight_vp = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list_vp.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'on');
pop_savemyerp(ERP_weight_vp, 'erpname',...
       'grand_avg_weight_vp', 'filename', 'grand_avg_weight_vp.erp', 'filepath',fullfile(home_dir, 'ERP') , 'Warning', 'off');
   
ERP_noweigth_vp = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list_vp.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'off' );
pop_savemyerp(ERP_noweigth_vp, 'erpname',...
       'grand_avg_noweight_vp', 'filename', 'grand_avg_noweight_vp.erp', 'filepath',fullfile(home_dir, 'ERP') , 'Warning', 'off');
   
%% --- 11# warning 30% limit, rm redo
%% zero the world
restoredefaultpath