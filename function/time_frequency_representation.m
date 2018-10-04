function [tfr] = time_frequency_representation(cfg,data)
trf = [];

cfg.trials = ones(1,length(data.trial)) == 1;
tfr = ft_freqanalysis(cfg, data);
end