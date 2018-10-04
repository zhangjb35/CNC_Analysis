save cnc_eeg.mat lay       % save the layout in the variable "lay" to a MATLAB file
%% 
for i=1:length(avgDataset)
    cfg = [];
    %cfg.baseline     = [-0.8 -0.6];
    %cfg.baselinetype = 'relchange';
    cfg.channel = {'all','-HEO','-VEO'};
    % cfg.channel  = {'all', '-PO10', '-PO9'};
    cfg.layout = 'cnc_eeg.mat';
    cfg.xlim         = [-0.5 -0.1];
    cfg.zlim         = [-0.5 2.5];
    cfg.style  = 'both';
    cfg.comment = 'no';
    cfg.ylim         = [8 12];
    cfg.marker       = 'on';
    cfg.gridscale  = 300;
    cfg.shading  = 'flat';
    cfg.marker = 'labels';
    cfg.colorbar           = 'yes';
    cfg.interplimits = 'head';
    %cfg.plotrad = 100;
    cfg.parameter  = 'powspctrm';
    cfg.interpolation = 'v4';
    %cfg.highlight          = {'labels'};
    %cfg.highlightsymbol    = {'o'};       % the empty option will be defaulted
    %cfg.highlightcolor     = {'r'};      % the missing option will be defaulted
    figure
    fnames = fieldnames(avgDataset{i});
    eval(['ft_topoplotTFR(cfg, avgDataset' '{' num2str(i) '}' '.' cell2mat(fnames) ');'])
    c=colormap(brewermap(1024, '*RdYlBu'));
    title(cell2mat(fnames));
    %colormap(c(513:end,:)); %only uses the hot portion of the color map
    print([cell2mat(fnames) sprintf('%02d',i)],'-dpng','-r300')
    close all
end