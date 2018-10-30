clear
clc
load ML_Control_stat.mat

%% plot
cfg = [];
%cfg.baseline = [-0.5 -0.1];
%cfg.zlim = [-3e-27 3e-27];
cfg.baselinetype = 'absolute';
cfg.parameter     = 'stat';  % plot the t-value 
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.layout = './setup/cnc_eeg.mat';
cfg.interactive = 'yes';
cfg.maskstyle = 'opacity';
cfg.maskalpha=0;
 cfg.showlabels ='yes';
 cfg.fontsize=12;
 cfg.showcomment='yes';
 cfg.zlim =[-10 10];
 cfg.colorbar ='yes';
 cfg.colormap='jet';
 cfg.showlabels='yes';
figure; ft_multiplotTFR(cfg,ML_Control);
print ML_Control_stat_results -dpng -r300