function fieldtripLayout = convert2layout(eeglabLayoutExport, refData)
% load and prep
cfg = [];
cfg.elecfile=eeglabLayoutExport;

% omit eog
cfg_omit=[];
cfg_omit.channel={'all', '-HEO', '-VEO'};
refDataUsed = ft_selectdata(cfg_omit,refData);

% prep layout
lay = ft_prepare_layout(cfg,refDataUsed);

%% refine the layout

% bigger head
% for i =1:1:size(lay.outline, 2)
%     lay.outline{1, i}= lay.outline{1, i}*1.12;
% end

% refine it, bigger range to show (go out the head)
for i =1:1:size(lay.mask, 2)
    lay.mask{1, i}= lay.mask{1, i}*1.12;
end

%% plot it to check
cfg = [];
cfg.layout = lay;   % this is the layout structure that you created with ft_prepare_layout
ft_layoutplot(cfg);

%% output
fieldtripLayout = cfg.layout;
end