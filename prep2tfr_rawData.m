% SET PATHS
clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/jinbo/Project/CNC/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, '/data/');
erp_setup_path = fullfile(home_dir,'erp');
figures_dir = []; % means no figures are saved

% ADD PATHS

% add your toolbox
addpath('/home/jinbo/.matlab/R2012b'); % for linux only
addpath(fullfile(matlab_dir, 'fieldtrip-20180922'));
ft_defaults %% initialize FieldTrip defaults
addpath(fullfile(matlab_dir, 'eeglab14_1_2b'));
% addpath(genpath(fullfile(matlab_dir, 'FastICA_25/')));
addpath(genpath(fullfile(matlab_dir, 'JinboToolbox/')));
% addpath(genpath(fullfile(matlab_dir, 'ERPWAVELABv1.2/')));

eeglab
eeglabpath = fileparts(which('eeglab')); % eeglab path

% detect target
[subjList,namePattern] = k_ls(fullfile(data_dir, 'sub-*', 'eeg', 'erp', 'ass_event_eeg.set'));
% please rm bad subj manully
% store path
storePath=fullfile(data_dir,'TFPrep');
mkdir(storePath)

bdfFile = k_ls(fullfile(erp_setup_path,'bdf_*.txt'));
%% ERP
[subjList,namePattern] = k_ls(fullfile(data_dir, 'sub-*', 'eeg', 'preprocess', 'coreog_ica_lfilt_hfilt_ref_data.set'));
for i=1:length(subjList)
    %% --- 01# load to EEGLAB
    EEG = pop_loadset('filename','coreog_ica_lfilt_hfilt_ref_data.set','filepath',fullfile([filesep namePattern,sprintf('%02d',i)],'eeg','preprocess'));
    
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
        EEG_epoch{j} = pop_epochbin( EEG_epoch{j} , [-1000 1500], [-200 0]);
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

%     %% --- 08# average [ERPLAB]
%     ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
%     EEG.setname='avg_artifact_epoch_ass_event_eeg';
%     
%     %% --- 09# save ERP [ERPLAB]
%     ERP = pop_savemyerp(ERP, 'erpname',...
%         ['sub-' sprintf('%02d',i)], 'filename',  ['sub-' sprintf('%02d',i) '.erp'], 'filepath',storePath, 'Warning', 'off');
    
% for i=1:length(subjList)
%     %% --- 01# sync epoch for TFR
%      % load
%      EEG = pop_loadset('filename','ass_event_eeg.set','filepath',fullfile([filesep namePattern,sprintf('%02d',i)],'eeg','erp'));
%      % epoch for TF
%      EEG = pop_epochbin( EEG , [-1000 1500], [-200 0]);
%     EEG.setname='epoch_ass_event_eeg';
%     
%      EEG  = pop_artextval( EEG , 'Channel',  1:62, 'Flag', [ 1 2], 'Threshold', [ -70 70], 'Twindow', [-200 798] );
%          EEG = pop_summary_AR_eeg_detection(EEG);
%     EEG.setname='artifact_epoch_ass_event_eeg';
%     subjList{i}
% end
% %% --- 02# import to BrainStorm
% %% --- 03# TFR
% %% --- 04# Total
% %% --- 05# Evoked
% %% --- 06# Induced