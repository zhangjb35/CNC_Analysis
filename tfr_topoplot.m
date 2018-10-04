%% Topoplot
% for further demonstrate the meaning of the results

%% prep toolbox, functions

% zero the world
clear, clc
restoredefaultpath; %% set a clean path

% toolbox
home_dir = '/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis';
toolbox_dir = fullfile(home_dir, 'toolbox');
fuction_dir = fullfile(home_dir, 'functions');
addpath(fullfile(toolbox_dir, 'fieldtrip-20180922')); ft_defaults;
addpath(genpath(fullfile(toolbox_dir, 'eeglab14_1_2b')));

% function
addpath(genpath(fuction_dir));

%% prep data
% for single condition (condition AVG)
conditionAVG = kb_ls(fullfile(home_dir,'data','conditionAVG','*.mat'));
for i=1:numel(conditionAVG)
    conditionFig{i} = load(conditionAVG{i},'-mat');
end
% for single condition (effect AVG)
effectAVG = kb_ls(fullfile(home_dir,'data','effectAVG','*.mat'));
for i=1:numel(effectAVG)
    effectFig{i} = load(effectAVG{i},'-mat');
end
% for final interaction effect
load('./data/effectAVG/MS_ML_avg.mat','-mat')
load('./data/effectAVG/OS_OL_avg.mat','-mat')
temp = MS_ML_avg;
finalInteraction = temp.powspctrm-OS_OL_avg.powspctrm;
save('./data/interaction/interactionAVG','finalInteraction')
clear *avg

%% topo plot prep
% get location information from EEGLAB
EEG = pop_loadset('filename','sub-01_bdf_01.set','filepath',fullfile(home_dir,'/data/TFPrep/'));
EEG=pop_chanedit(EEG, 'eval','pop_writelocs( chans, ''/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis/setup/eeglab_loc.sfp'', ''filetype'',''sfp'',''format'',{''labels'' ''-Y'' ''X'' ''Z''},''header'',''off'',''customheader'','''');');
lay = convert2layout('/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis/setup/eeglab_loc.sfp',finalInteraction);
for j=1:(numel(conditionAVG)+numel(effectAVG)+1)
    if j<=numel(conditionAVG)+numel(effectAVG)+1
    elseif j<=numel(conditionAVG)+numel(effectAVG)
    elseif j<=numel(conditionAVG)
    end
end
