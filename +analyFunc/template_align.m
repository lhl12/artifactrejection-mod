function [templateArrayCell, maxLocation] = template_align(templateArrayCell, maxIdxArray, alignmentSimilarity)

    maxLocation = zeros(1, size(templateArrayCell, 2));
    for chan = 1:length(templateArrayCell)
        
        template = templateArrayCell{chan};
        idx = maxIdxArray{chan};
        ctr = floor(median(idx));
        len = size(template, 1);
        newLen = len + max(ctr - idx) + max(idx - ctr);
        newCtr = ctr + max(idx - ctr);
        templateAligned = nan(newLen, size(template, 2));
        
        % align to max
        for trial = 1:size(template, 2)
            frontPad = newCtr - idx(trial);
            endPad = newLen - (len + frontPad);
            templateTrial = padarray(template(:, trial), frontPad, 0, 'pre');
            templateTrial = padarray(templateTrial, endPad, 0, 'post');
            templateAligned(:, trial) = templateTrial;
        end
        
        % align by cross-correlation
        [templateAligned, newCtr] = analyFunc.xcorr_align(templateAligned, 5, newCtr, alignmentSimilarity);
        
        templateArrayCell{chan} = templateAligned;
        if isempty(newCtr)
            newCtr = nan;
        end
        maxLocation(chan) = newCtr;
    end

end

