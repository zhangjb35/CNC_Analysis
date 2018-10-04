function [untimelocked_data] = untimelocked_analysis(input_variables, addition_variable)
% This function removed the trial average from each at each time sample
%
% cfg must contain:
%
%   cfg.events = a cell array containing the event numbers for all events
%   to be untimelocked
%
% input_variable{1} should be epoched data and input_variable{2} should be
% timelocked

untimelocked_data = addition_variable;
timelockeds = input_variables;

for i=1:length(untimelocked_data.trial)
    disp(['Removing average responses #' sprintf('%02d',i)]);
    untimelocked_data.trial{i} = untimelocked_data.trial{i} - timelockeds.avg;
end