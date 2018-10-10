function kb_plot_tfr(roi,diff_map_oi,trange,frange,fig_titile,outputfile,maskfile,outputfile_after_mask,crange,bsl)
%% diff time-freq map for perticular sites of electrodes
% get target information
if ~isempty(roi)
    cfg=[];
    cfg.channel          = roi;
    freq_avg_frontal = ft_freqdescriptives(cfg,diff_map_oi); % select data from frontal sites
    meanpow = squeeze(mean(freq_avg_frontal.powspctrm, 1)); % average across frontal sites
else
    cfg=[];
    cfg.channel          = diff_map_oi.label(1:end-2); % exclude EOG
    freq_avg_frontal = ft_freqdescriptives(cfg,diff_map_oi); % select data from frontal sites
    meanpow = squeeze(mean(freq_avg_frontal.powspctrm, 1)); % average across frontal sites
end
if ~isempty(bsl)
    baselineFactor = mean(meanpow(:,[find(freq_avg_frontal.time==bsl(1)):find(freq_avg_frontal.time==bsl(2))]),2);
    % meanpow = (meanpow - repmat(baselineFactor,1,size(meanpow,2)))./repmat(baselineFactor,1,size(meanpow,2));
    meanpow = (meanpow - repmat(baselineFactor,1,size(meanpow,2)));
end
% refine the data for more beatuful plot
% finer time and frequency axes:
tim_interp = linspace(trange(1), trange(2), 256);
freq_interp = linspace(frange(1), frange(2), 256);

% make a full time/frequency grid of both the original and interpolated
% coordinates. Matlab's meshgrid() used
[tim_grid_orig, freq_grid_orig] = meshgrid(freq_avg_frontal.time, freq_avg_frontal.freq);
[tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);
meanpow = inpaint_nans(meanpow,2);

% generate final interpolated powerspec
pow_interp = interpn(tim_grid_orig', freq_grid_orig', meanpow',tim_grid_interp, freq_grid_interp, 'spline');

% plot the beatuful version
fig = figure();
im_main = imagesc(tim_interp, freq_interp, pow_interp);
pbaspect([2 0.66 1]) % adjust the ratio to 2:0.66 (x:y)
xlim(trange);
ylim(frange);
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
caxis(crange);
colormap(brewermap(256, '*RdYlBu')); % refine the colorbar
%colormap(bluewhitered(1024))
%colormap(jet) % set classical colmap

% refine the detail of display
h = colorbar();
% axis tight
title(fig_titile,'FontWeight','bold');
set(findall(gcf,'-property','FontSize'),'FontSize',18)
set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
% set(h, 'YTick', [-1 -0.25 0 0.25 1]);
% set(h, 'yticklabel', {-100 -25 0 25 100});
% ylabel(h, 'Power Change Based on No Sound Condition (%)');

% draw stim onset marker
hold on;
plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
hold off;
% output the picture
print(fig,outputfile,'-dpng','-r300')
% close file
% close all

% applay mask file on it for stat demo
if ~isempty(maskfile)
    disp('detected mask, use it');
    % plot figure with the mask
    fig = figure();
    im_main = imagesc(freq_avg_frontal.time, freq_avg_frontal.freq, meanpow.*maskfile);
    pbaspect([2 0.66 1]) % adjust the ratio to 2:0.66 (x:y)
    xlim(trange);
    ylim(frange);
    axis xy;
    xlabel('Time (ms)');
    ylabel('Frequency (Hz)');
    caxis(crange);
    colormap(brewermap(256, '*RdYlBu')); % refine the colorbar
    %colormap(bluewhitered(1024))
    %colormap(jet) % set classical colmap
    
    % refine the detail of display
    h = colorbar();
    % axis tight
    title(fig_titile,'FontWeight','bold');
    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
    set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
    set(h, 'YTick', [-1 -0.25 0 0.25 1]);
    set(h, 'yticklabel', {-100 -25 0 25 100});
    % ylabel(h, 'Power Change Based on No Sound Condition (%)');
    
    % draw stim onset marker
    hold on;
    plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
    plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
    hold off;
    % output the picture
    print(fig,outputfile_after_mask,'-dpng','-r300')
end

% close file
% close all
end

