clear
clc
load SP_Theta.mat

%% plot
cfg = [];
%cfg.baseline = [-0.5 -0.1];
%cfg.zlim = [-3e-27 3e-27];
cfg.baselinetype = 'absolute';
cfg.parameter     = 'stat';  % plot the t-value 
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.layout = 'cnc_eeg.mat';
cfg.interactive = 'yes';
cfg.maskstyle = 'opacity';
cfg.maskalpha=0;
 cfg.showlabels ='yes';
 cfg.fontsize=12;
 cfg.showcomment='no';
 cfg.colorbar ='yes';
 cfg.colormap='jet'
figure; ft_multiplotTFR(cfg,SP_Beta);