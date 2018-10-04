%% frotnal
load MS_MLAVG
load OS_OLAVG
temp = MS_MLAVG;
temp.powspctrm =  temp.powspctrm - OS_OLAVG.powspctrm;
diff_map = temp;
clear temp
 
cfg=[];
%cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
freq_avg_frontal = ft_freqdescriptives(cfg,diff_map);
meanpow = squeeze(mean(freq_avg_frontal.powspctrm, 1));
% The finer time and frequency axes:
tim_interp = linspace(-0.8, 0.8, 256);
freq_interp = linspace(4, 30, 256);
% We need to make a full time/frequency grid of both the original and
% interpolated coordinates. Matlab's meshgrid() does this for us:
[tim_grid_orig, freq_grid_orig] = meshgrid(freq_avg_frontal.time, freq_avg_frontal.freq);
[tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);
meanpow = inpaint_nans(meanpow,2);
% And interpolate:
pow_interp = interpn(tim_grid_orig', freq_grid_orig', meanpow',tim_grid_interp, freq_grid_interp, 'spline');

fig = figure();
im_main = imagesc(tim_interp, freq_interp, pow_interp);
 pbaspect([2 0.66 1])
xlim([-0.8 0.8]);
ylim([4 30]);
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
caxis([-0.25 0.25]);
colormap(brewermap(256, '*RdYlBu'));
%colormap(bluewhitered(1024)) 
colormap(jet)
h = colorbar();
axis tight
 title('Interaction Effect (Frontal-centrol Sites)','FontWeight','bold');
 set(findall(gcf,'-property','FontSize'),'FontSize',18)
 set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
 set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
 set(h, 'YTick', [-1 -0.25 0 0.25 1]);
 set(h, 'yticklabel', {-100 -25 0 25 100});

% ylabel(h, 'Power Change Based on No Sound Condition (%)');
 hold on;
 plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 print(fig,'frontal','-dpng','-r300')
 %% posterior
 cfg=[];
cfg.channel          = {'CPz', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', 'CP6', 'Pz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'POz', 'PO3', 'PO4', 'PO7', 'PO8', 'Oz', 'O1', 'O2'};
%cfg.channel          = {'Fz', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'FCz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Cz', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'};
freq_avg_frontal = ft_freqdescriptives(cfg,diff_map);
meanpow = squeeze(mean(freq_avg_frontal.powspctrm, 1));
% The finer time and frequency axes:
tim_interp = linspace(-0.8, 0.8, 256);
freq_interp = linspace(4, 30, 256);
% We need to make a full time/frequency grid of both the original and
% interpolated coordinates. Matlab's meshgrid() does this for us:
[tim_grid_orig, freq_grid_orig] = meshgrid(freq_avg_frontal.time, freq_avg_frontal.freq);
[tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);
meanpow = inpaint_nans(meanpow,2);
% And interpolate:
pow_interp = interpn(tim_grid_orig', freq_grid_orig', meanpow',tim_grid_interp, freq_grid_interp, 'spline');

fig = figure();
im_main = imagesc(tim_interp, freq_interp, pow_interp);
 pbaspect([2 0.66 1])
xlim([-0.8 0.8]);
ylim([4 30]);
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
caxis([-0.25 0.25]);
colormap(brewermap(256, '*RdYlBu'));
%colormap(bluewhitered(1024)) 
colormap(jet)
h = colorbar();
axis tight
 title('Interaction Effect (Posterior-centrol Sites)','FontWeight','bold');
 set(findall(gcf,'-property','FontSize'),'FontSize',18)
 set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
 set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
 set(h, 'YTick', [-1 -0.25 0 0.25 1]);
 set(h, 'yticklabel', {-100 -25 0 25 100});

% ylabel(h, 'Power Change Based on No Sound Condition (%)');
 hold on;
 plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 print(fig,'posterior','-dpng','-r300')
 %% add mask
 stat = stat_interaction_alpha;
 mask = squeeze(stat.mask);
 % gen new mask as size of tfr
 newMask = zeros(size(meanpow));
 newMask((1:size(mask,1))+find(freq_avg_frontal.freq==stat.freq(1))-1,(1:size(mask,2))+find(freq_avg_frontal.time==stat.time(1))-1) =  mask;
%%
% B=[0 1 0; 1 1 1; 0 1 0];
% I2=imerode(newMask,B2);
% I3=newMask-I2;
% imagesc(I3)
%
% axis xy
% b = bwboundaries(newMask.','noholes');
% x = b{1}(:,1);
% y = b{1}(:,2);
% X = reshape(bsxfun(@plus,x,[0 -0.25 0.25]),[],1);
% Y = reshape(bsxfun(@plus,y,[0 0.25 -0.25]),[],1);
% k = boundary(X,Y,1);
fig=figure;
%im_main = imagesc(tim_interp, freq_interp, pow_interp);
%im_main = imagesc(tim_interp, freq_interp, newMask);
im_main = imagesc(freq_avg_frontal.time, freq_avg_frontal.freq, meanpow.*newMask);
%hold on
% plot(X(k)*(stat.time(2)-stat.time(1))+min(stat.time),Y(k)*(stat.freq(2)-stat.freq(1))+min(stat.freq),'k','LineWidth',1,'Marker','none',...
%     'MarkerFaceColor','none','MarkerEdgeColor','none')
% axis xy
pbaspect([2 0.66 1])
xlim([-0.8 0.8]);
ylim([4 30]);
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
caxis([-0.25 0.25]);
colormap(brewermap(256, '*RdYlBu'));
%colormap(bluewhitered(1024)) 
colormap(jet)
h = colorbar();
%axis tight
 title('Interaction Effect (Posterior-centrol Sites)','FontWeight','bold');
 set(findall(gcf,'-property','FontSize'),'FontSize',18)
 set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
 set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
 set(h, 'YTick', [-1 -0.25 0 0.25 1]);
 set(h, 'yticklabel', {-100 -25 0 25 100});

% ylabel(h, 'Power Change Based on No Sound Condition (%)');
 hold on;
 plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 print(fig,'posterior_stat','-dpng','-r300')
% J = imresize(newMask, 1.01);
% newMask = zeros(size(J));
% newMask((1:size(mask,1))+10,(1:size(mask,2))+20) = mask;
% imagesc(newMask);
% temp = J-newMask;
% imagesc(temp);
%%
effect = OS_OLAVG.powspctrm;
siz    = size(effect);
%effect = reshape(effect, siz(2:end)); % we need to "squeeze" out one of the dimensions, i.e. make it 3-D rather than 4-D

stat.effect = effect;
cfg = [];
%cfg.channel       = {'MEG1243'};
%cfg.baseline      = [-inf 0];
cfg.renderer      = 'openGL';     % painters does not support opacity, openGL does
cfg.colorbar      = 'yes';
%cfg.parameter     = 'stat';     % display the power
cfg.parameter     = 'effect'; 
cfg.maskparameter = 'mask';       % use significance to mask the power
cfg.maskalpha     = 0.3;          % make non-significant regions 30% visible
cfg.zlim          = 'maxabs';
cfg.maskstyle = 'opacity'
figure

ft_singleplotTFR(cfg,stat)
%%
imagesc(newMask);


%% total
 clear temp
 temp = MS_MLAVG;
 temp.powspctrm =  temp.powspctrm - OS_OLAVG.powspctrm;
 simple_s_l = temp;
 clear temp
 
 cfg=[];
freq_avg = ft_freqdescriptives(cfg,simple_s_l);
meanpow = squeeze(mean(freq_avg.powspctrm, 1));
% The finer time and frequency axes:
tim_interp = linspace(-0.8, 0.8, 256);
freq_interp = linspace(4, 30, 256);
% We need to make a full time/frequency grid of both the original and
% interpolated coordinates. Matlab's meshgrid() does this for us:
[tim_grid_orig, freq_grid_orig] = meshgrid(freq_avg.time, freq_avg.freq);
[tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);
meanpow = inpaint_nans(meanpow,2);
% And interpolate:
pow_interp = interpn(tim_grid_orig', freq_grid_orig', meanpow',tim_grid_interp, freq_grid_interp, 'spline');

fig = figure();
im_main = imagesc(tim_interp, freq_interp, pow_interp);
 pbaspect([2 0.66 1])
xlim([-0.8 0.8]);
ylim([4 30]);
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
caxis([-0.25 0.25]);
colormap(brewermap(256, '*RdYlBu'));
%colormap(bluewhitered(1024)) 
colormap(jet)
h = colorbar();
axis tight
 title('Interaction Effect (All Sites)','FontWeight','bold');
 set(findall(gcf,'-property','FontSize'),'FontSize',18)
 set(gca,'XTick',[-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
 set(gca,'xticklabel',({'-800' '' '-400' '' '0' '' '400' '' '800'}))
 set(h, 'YTick', [-1 -0.25 0 0.25 1]);
 set(h, 'yticklabel', {-100 -25 0 25 100});

 %ylabel(h, 'Power Change Based on No Sound Condition (%)');
 hold on;
 plot(zeros(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 plot(-0.5*ones(size(freq_interp)), freq_interp, 'k--','LineWidth',1);
 print(fig,'all_diff','-dpng','-r300')