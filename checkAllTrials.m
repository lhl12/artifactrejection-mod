function [] = checkAllTrials(data, artrem, annode, cathode, onsets_samps, fsData, pre, post)

    nTrials = length(onsets_samps);
    starts = onsets_samps - round(fsData*pre);
    stops = onsets_samps + round(fsData*post);
    
    tEpoch = -pre:(1/fsData):post;
    
    nFig = ceil(nTrials/100);
    
    for ff = 1:nFig
        
        figure;
        if ff ~= nFig
            subs = [10, 10];
            nSub = 100;
        else
            nSub = nTrials - (100*(nFig - 1));
            subs(1) = floor(sqrt(nSub));
            subs(2) = ceil(nSub/subs(1));
        end
        
        for ss = 1:nSub
            
            subplot(subs(1), subs(2), ss);
            trialNum = ss + (100*(ff - 1));
            chansUse = 1:size(data, 2);
            chansUse(chansUse == annode(trialNum) | chansUse == cathode(trialNum)) = [];
            
            plot(tEpoch, artrem(starts(ss):stops(ss), chansUse));
            
            title(sprintf('Trial %d', trialNum));
            
            ylim([-1e-4 1e-4]);
            
            vline(0, 'k:');
            
        end
        
    end

end

