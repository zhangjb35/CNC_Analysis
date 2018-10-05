% SET PATHS
clear variables
restoredefaultpath; %% set a clean path
home_dir = pwd;

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, '/data/rawEEG');
erp_setup_path = fullfile(home_dir,'/setup');

% ADD PATHS

% add your toolbox
% addpath('/home/jinbo/.matlab/R2012b'); % for linux only
addpath(fullfile(matlab_dir, 'fieldtrip-20180922'));ft_defaults %% initialize FieldTrip defaults
addpath(genpath(fullfile(matlab_dir, 'eeglab14_1_2b')));
eeglabpath = fileparts(which('eeglab')); % eeglab path

bdfFile = fullfile(erp_setup_path,'bdf.txt');
%% ERP
[subjList,namePattern] = kb_ls(fullfile(data_dir, 'sub-*', 'eeg', 'preprocess', 'coreog_ica_lfilt_hfilt_ref_data.set'));
for i=1:length(subjList)
    %% --- 01# prepare path
    % setup store path
    storePath=fullfile(home_dir,['sub-' sprintf('%02d',i)],'eeg','erp_70uv_threshodl');
    mkdir(storePath);
    %% --- 02# load to EEGLAB
    EEG = pop_loadset('filename','coreog_ica_lfilt_hfilt_ref_data.set','filepath',fullfile([filesep namePattern,sprintf('%02d',i)],'eeg','preprocess'));
    
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
    EEG  = pop_binlister( EEG , 'BDF', bdfFile, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput',...
        'EEG' );
    EEG.setname='ass_event_eeg';
    pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
    
    %% --- 06# extract epoch [ERPLAB]
    EEG = pop_epochbin( EEG , [-200 800], 'pre');
    EEG.setname='epoch_ass_event_eeg';
    pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
    
    %% --- 07# artifacts reject [ERPLAB]
    EEG  = pop_artextval( EEG , 'Channel',  1:62, 'Flag', [ 1 2], 'Threshold', [ -70 70], 'Twindow', [-200 798] );
    EEG.setname='artifact_epoch_ass_event_eeg';
    EEG = pop_summary_AR_eeg_detection(EEG, fullfile(storePath, [EEG.setname, '.txt']));
    pop_saveset(EEG, 'filename', EEG.setname, 'filepath', storePath);
    
    %% --- 08# average [ERPLAB]
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    EEG.setname='avg_artifact_epoch_ass_event_eeg';
    
    %% --- 09# save ERP [ERPLAB]
    ERP = pop_savemyerp(ERP, 'erpname',...
        ['sub-' sprintf('%02d',i)], 'filename',  ['sub-' sprintf('%02d',i) '.erp'], 'filepath',storePath, 'Warning', 'off');
    % clear up
    clear EEG
end
%% --- 10# grand avage  [ERPLAB]
% get individual subject erp file list
all_ERP = kb_ls(fullfile(data_dir, 'sub-*', 'eeg', 'erp_70uv_threshodl', '*.erp'));
dlmcell( 'grandAVG_list.txt',all_ERP);
movefile('grandAVG_list.txt',[home_dir, filesep, 'ERP']);
% grand average and save grand erp
ERP_weight = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'on');
pop_savemyerp(ERP_weight, 'erpname',...
       'grand_avg_weight', 'filename', 'grand_avg_weight.erp', 'filepath',fullfile(home_dir, 'erp') , 'Warning', 'off');
   
ERP_noweigth = pop_gaverager(fullfile(home_dir, 'ERP', 'grandAVG_list.txt') , 'Criterion',  30, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'off' );
pop_savemyerp(ERP_noweigth, 'erpname',...
       'grand_avg_noweight', 'filename', 'grand_avg_noweight.erp', 'filepath',fullfile(home_dir, 'erp') , 'Warning', 'off');
%% --- 11# warning 30% limit, rm redo