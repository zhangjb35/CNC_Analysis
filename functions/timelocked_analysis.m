function [timelocked_data] = timelocked_analysis(cfg, input_variables)
% This function averages data at each time sample
%
% cfg must contain:
%
%   cfg.events = a cell array containing the event numbers for all events
%   to be timelocked
%
% cfg can contain anything that ft_timelockanalysis recognizes

timelocked_data = [];
cfg.trials = ones(1,length(input_variables.trial)) == 1;
timelocked_data = ft_timelockanalysis(cfg, input_variables);