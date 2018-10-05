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
interactionAVG = MS_ML_avg;
interactionAVG.powspctrm = MS_ML_avg.powspctrm-OS_OL_avg.powspctrm;
save('./data/interaction/interactionAVG','interactionAVG')
clear *avg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% topo plot prep
% get location information from EEGLAB
EEG = pop_loadset('filename','sub-01_bdf_01.set','filepath',fullfile(home_dir,'/data/TFPrep/'));
EEG=pop_chanedit(EEG, 'eval','pop_writelocs( chans, ''/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis/setup/eeglab_loc.sfp'', ''filetype'',''sfp'',''format'',{''labels'' ''-Y'' ''X'' ''Z''},''header'',''off'',''customheader'','''');');
lay = convert2layout('/Volumes/Workspace/Projects/CNC_analysis/code/CNC_Analysis/setup/eeglab_loc.sfp',interactionAVG);
save ./setup/cnc_eeg.mat lay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
% for single condition
% need four plot
outputName{1} = 'SP Theta';
outputName{2} = 'SP Beta E1';
outputName{3} = 'SP Beta E2';
outputName{4} = 'VP Alpha';
outputName{5} = 'VPBeta';

% need t-f regions
trangeSet{1} = [-0.5 -0.2];
trangeSet{2} = [-0.4 -.02];
trangeSet{3} = [-0.2 0];
trangeSet{4} = [0 3.5];
trangeSet{5} = [0.5 2.5];

frangeSet{1}=[4 8];
frangeSet{2}=[12 18];
frangeSet{3}=[12 18];
frangeSet{4}=[7.5 10.5];
frangeSet{5}=[12 15];

% select the range is a work of art, so do it begin stupid
% crangeSet{1}=[];
%crangeSet{2}=[];
% crangeSet{3}=[];
% crangeSet{4}=[];
% crangeSet{5}=[];

crangeSet{1}=[0 2]+1;
crangeSet{2}=[0 0.25]+1;
crangeSet{3}=[0 0.25]+1;
crangeSet{4}=[-0.2 0]+1;
crangeSet{5}=[-0.2 0]+1;

for i=1:numel(conditionAVG)
    fieldName = cell2mat(fieldnames(conditionFig{i}));
    eval(['plotTarget = conditionFig{i} .' fieldName]);
    cfg=[];
    cfg.channel={'all', '-HEO', '-VEO'};
    plotTarget=ft_selectdata(cfg,plotTarget);
    % plot
    layout = fullfile(home_dir,'setup','cnc_eeg.mat');
    for j=1:length(trangeSet)
        trange = trangeSet{j};
        frange = frangeSet{j};
        crange = crangeSet{j};
        kb_plot_topoplot_fun(layout,trange,frange,crange,plotTarget,[fieldName '-' outputName{j}])
    end
end
%% close file
close all

%%%%%%%%%%%%%%%%%%%%%%%%%
% for single condition
% need four plot
outputName{1} = 'SP Theta';
outputName{2} = 'SP Beta E1';
outputName{3} = 'SP Beta E2';
outputName{4} = 'VP Alpha';
outputName{5} = 'VPBeta';

% need t-f regions
trangeSet{1} = [-0.5 -0.2];
trangeSet{2} = [-0.4 -.02];
trangeSet{3} = [-0.2 0];
trangeSet{4} = [0 3.5];
trangeSet{5} = [0.5 2.5];

frangeSet{1}=[4 8];
frangeSet{2}=[12 18];
frangeSet{3}=[12 18];
frangeSet{4}=[7.5 10.5];
frangeSet{5}=[12 15];

% select the range is a work of art, so do it begin stupid
crangeSet{1}=[];
crangeSet{2}=[];
crangeSet{3}=[];
crangeSet{4}=[];
crangeSet{5}=[];

% crangeSet{1}=[0 2];
% crangeSet{2}=[0 0.25];
% crangeSet{3}=[0 0.25];
% crangeSet{4}=[-0.2 0];
% crangeSet{5}=[-0.2 0];

for i=1:numel(effectFig)
    fieldName = cell2mat(fieldnames(effectFig{i}));
    eval(['plotTarget = effectFig{i} .' fieldName]);
    cfg=[];
    cfg.channel={'all', '-HEO', '-VEO'};
    plotTarget=ft_selectdata(cfg,plotTarget);
    % plot
    layout = fullfile(home_dir,'setup','cnc_eeg.mat');
    for j=1:length(trangeSet)
        trange = trangeSet{j};
        frange = frangeSet{j};
        crange = crangeSet{j};
        kb_plot_topoplot_fun(layout,trange,frange,crange,plotTarget,[fieldName '-' outputName{j}])
    end
end
%% close file
close all

%%%%%%%%%%%%%%%%%%%%
% for final interaction
% need four plot
outputName{1} = 'SP Theta';
outputName{2} = 'SP Beta E1';
outputName{3} = 'SP Beta E2';
outputName{4} = 'VP Alpha';
outputName{5} = 'VPBeta';

% need t-f regions
trangeSet{1} = [-0.5 -0.2];
trangeSet{2} = [-0.4 -.02];
trangeSet{3} = [-0.2 0];
trangeSet{4} = [0 3.5];
trangeSet{5} = [0.5 2.5];

frangeSet{1}=[4 8];
frangeSet{2}=[12 18];
frangeSet{3}=[12 18];
frangeSet{4}=[7.5 10.5];
frangeSet{5}=[12 15];

% select the range is a work of art, so do it begin stupid
crangeSet{1}=[];
crangeSet{2}=[];
crangeSet{3}=[];
crangeSet{4}=[];
crangeSet{5}=[];

% plot it
    plotTarget = interactionAVG;
    cfg=[];
    cfg.channel={'all', '-HEO', '-VEO'};
    plotTarget=ft_selectdata(cfg,plotTarget);
    % plot
    layout = fullfile(home_dir,'setup','cnc_eeg.mat');
    for j=1:length(trangeSet)
        trange = trangeSet{j};
        frange = frangeSet{j};
        crange = crangeSet{j};
        kb_plot_topoplot_fun(layout,trange,frange,crange,plotTarget,['Interaction-' outputName{j}])
    end