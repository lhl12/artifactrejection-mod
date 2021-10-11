function [sigOut, numOut] = interp_spikes(processedSig, cutoff, onsets_samps, pm, stimChans)
sigOut = processedSig;
numOut = 0;
pctl = @(v,p) interp1(linspace(0.5/length(v), 1-0.5/length(v), length(v))', ...
    sort(v), p*0.01, 'spline');

for chan = 1:size(processedSig, 2)

    for trial = 1:length(onsets_samps)
        
        if ismember(chan, stimChans(trial, :))
            continue
        else
            win = (onsets_samps(trial)-pm):(onsets_samps(trial)+pm);
            sig = processedSig(win, chan);
            sigAlt = sig;
            diffsig = abs(zscore(diff(sig)));
            thresh = pctl(diffsig, cutoff);

            inds = find(diffsig > thresh);
            if isempty(inds)
                continue;
            end
            inds = arrayfun(@(x) x-5:x+5, inds, 'UniformOutput', false);
            inds = unique([inds{:}]);
            inds(inds < 1) = [];
            inds(inds > length(win)) = [];

            diffinds = diff(inds);
            starts = inds([1 (find(diffinds ~= 1)+1)]);
            stops = inds([find(diffinds ~= 1) length(inds)]);
            len = stops - starts + 1;
            rem = find(len > 24);
            if ~isempty(rem)
                starts(rem) = [];
                stops(rem) = [];
                warning('A spike/spikes of >24 samples is not being interpolated');
            end

        %         figure;
            for idx = 1:length(starts)

        %             lims = [max(starts(idx) - 5, 1) min(stops(idx) + 5, length(sig))];

        %             subplot(1, length(starts), idx);
                sigAlt(starts(idx):stops(idx)) = NaN;
                sigAlt = fillmissing(sigAlt, 'linear');
        %             plot(sig(lims(1):lims(2)), 'k', 'LineWidth', 3);
        %             hold on
        %             plot(sigAlt(lims(1):lims(2)), 'r', 'LineWidth', 2);
        %             title(sprintf('Channel %d Trial %d', chan, trl));

                numOut = numOut + 1;
            end

            sigOut(win, chan) = sigAlt;
        end
    end
end
end

