function kb_plot_topoplot_fun(layout,trange,frange,crange,tfr_data,outputFile)
cfg = [];
%cfg.baseline     = [-0.8 -0.6];
%cfg.baselinetype = 'relchange';
%cfg.channel = {'all','-HEO','-VEO'};
% cfg.channel  = {'all', '-PO10', '-PO9'};
cfg.layout = layout;
cfg.xlim         = trange;
cfg.ylim         = frange;
cfg.zlim         = crange;
cfg.style  = 'both';
cfg.comment = 'no';

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
temp = tfr_data;
temp.powspctrm=temp.powspctrm;
ft_topoplotTFR(cfg, temp)
colormap(brewermap(1024, '*RdYlBu'));
c = colormap('jet');
% if mean(crange) > 0
%     colormap(c(513:end,:));
% else
%     colormap(c(1:512,:));
% end

%colormap(bluewhitered(1024))
title(outputFile);
%colormap(c(513:end,:)); %only uses the hot portion of the color map
print(outputFile,'-dpng','-r300')
%close all
end

