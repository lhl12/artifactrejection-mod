function [chck] = assess_removal(processedSig, startInds, endInds, z_cutoff)

    if ~exist('z_cutoff', 'var')
        z_cutoff = 5;
    end
    
    chck = nan(length(startInds), size(processedSig, 2));

    for trl = 1:length(startInds)
        
        for ch = 1:size(processedSig, 2)
            
            start_loc = startInds{trl}{ch};
            end_loc = endInds{trl}{ch};
            
            if ~isempty(start_loc) && ~isempty(end_loc)
                pre_start = start_loc - 500;
                pre_end = start_loc - 100;

                data_loc = processedSig(start_loc:end_loc, ch);
                baseline_loc = processedSig(pre_start:pre_end, ch);

                mu = mean(baseline_loc); sigma = std(baseline_loc);
                z_loc = abs((data_loc - mu)./sigma);
                
                if any(z_loc > z_cutoff)
                    chck(trl, ch) = false;
                else
                    chck(trl, ch) = true;
                end
                
            end
            
        end
        
    end

end

