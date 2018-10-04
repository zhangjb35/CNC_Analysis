function aioMask = kb_prep_mask(maskSets,targetPlot)
for i=1:length(maskSets)
    mask = squeeze(maskSets{i}.mask);
    if isequal(i,1)
        tempMask = zeros(length(targetPlot.freq),length(targetPlot.time));
        tempMask((1:size(mask,1))+find(targetPlot.freq==maskSets{i}.freq(1))-1,(1:size(mask,2))+find(targetPlot.time==maskSets{i}.time(1))-1) =  mask;
    else
        tempMask((1:size(mask,1))+find(targetPlot.freq==maskSets{i}.freq(1))-1,(1:size(mask,2))+find(targetPlot.time==maskSets{i}.time(1))-1) =  mask;
    end
    clear mask
end
aioMask = tempMask;
end

