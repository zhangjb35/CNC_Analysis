function output = loop_ana( input, action, cfg, additoininfo )
for i=1:numel(input)
    switch action
        case 'eeglab2fieldtrip'
            temp = pop_loadset(input{i});
            output{i} = eeglab2fieldtrip(temp,'preprocessing');
        case 'timelocked_analysis'
            temp = input{i};
            output{i} = timelocked_analysis(cfg,temp);
        case 'untimelocked_analysis'
            temp = input{i};
            temp_add = additoininfo{i};
            output{i} = untimelocked_analysis(temp,temp_add);
        case 'time_frequency_representation'
            temp = input{i};
            output{i} = time_frequency_representation(cfg,temp);
        case 'ft_multiplotTFR'
            temp = input{i};
            figure
            output{i} = ft_multiplotTFR(cfg,temp);
        case 'ft_topoplotTFR'
            temp = input{i};
            figure
            output{i} = ft_topoplotTFR(cfg,temp);
        case 'ft_singleplotTFR'
            temp = input{i};
            figure
            output{i} = ft_singleplotTFR(cfg,temp);
        case 'cond_baseline_ref'
            temp = input{i};
            temp_base = additoininfo{i};
            output{i} = input{i};
            rm_baseline_cond_data = repmat(nanmean(temp_base.powspctrm(:,:,:),3),[1 1 size(temp_base.powspctrm, 3)]);
            output{i}.powspctrm = temp.powspctrm ./ rm_baseline_cond_data;
        case 'diff_tf'
            temp = input{i};
            temp_base = additoininfo{i};
            output{i} = input{i};
            output{i}.powspctrm = temp.powspctrm - temp_base.powspctrm;
        case 'average_tf'
            temp = input{i};
            temp_base = additoininfo{i};
            output{i} = input{i};
            output{i}.powspctrm = (temp.powspctrm + temp_base.powspctrm)/2;
        otherwise
            disp('error');
    end
end
end