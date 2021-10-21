function [sigsAligned, ctr] = xcorr_align(sigs, maxLag, ctr, alignmentSimilarity)

    % case where it doesn't work: equal number of trials of two types AND
    % the trials are not clumped together (i.e. alignment matrix like:
    %                                       [0 -2  0 -2
    %                                        2  0  2  0
    %                                        0 -2  0 -2
    %                                        2  0  2  0])

    % for each trial pair, find whether there is any high cross correlation
    % and if so, what relative slide index has max cross correlation (no
    % high cross correlation -> nan)
    nTrls = size(sigs, 2);
    highCorr = nan(nTrls, nTrls);
    for ii = 1:nTrls
        for jj = 1:nTrls
            xcorrLoc = xcorr(sigs(:, ii), sigs(:, jj), maxLag, 'coeff');
            xcorrIdx = find(xcorrLoc > alignmentSimilarity);
            if ~isempty(xcorrIdx)
                [~, mxIdx] = max(xcorrLoc(xcorrIdx));
                highCorr(ii, jj) = xcorrIdx(mxIdx) - maxLag - 1;
            end
        end
    end
    
    lowerTri = tril(highCorr);
    lAdd = nanmax(abs(lowerTri(lowerTri < 0))); % pad front of array
    if isempty(lAdd); lAdd = 0; end
    rAdd = nanmax(abs(lowerTri(lowerTri > 0))); % pad end of array
    if isempty(rAdd); rAdd = 0; end
    
    sigsAligned = zeros(lAdd + rAdd + size(sigs, 1), nTrls);
    for ii = 1:nTrls
        locU = unique(highCorr(:, ii));
        locU = locU(~isnan(locU));
        if isempty(locU) % does not correlate highly with any other trial
            sigsAligned(:, ii) = [zeros(lAdd, 1); sigs(:, ii); zeros(rAdd, 1)];
        elseif ~ismember(locU, 0) % should always be a zero for autocorrelation at least
            error('I do not think this case will ever come up');
        elseif length(locU) == 1 % if length is 1, the only member is zero and it should not slide
            sigsAligned(:, ii) = [zeros(lAdd, 1); sigs(:, ii); zeros(rAdd, 1)]; % no slide
        else % if there are nonzero values
            cts = sum(highCorr(:, ii) == locU'); % count all unique values
            if length(unique(cts)) == length(cts) % if there are not two conditions with the same number of trials
                [~, maxIdx] = max(cts);
                slideBy = locU(maxIdx); % amount to slide by
                nonnan1 = find(highCorr(:, ii) == slideBy, 1);
                if nonnan1 > ii % reverse lower half of triangle
                    slideBy = -slideBy;
                end
                sigsAligned(:, ii) = [zeros(lAdd - slideBy, 1); sigs(:, ii); ...
                    zeros(rAdd + slideBy, 1)]; % slide by appropriate amount either left (slideBy < 0), right (slideBy > 0), or not at all (slideBy == 0)
            else % if two or more conditions have equal counts
                % find the first non-nan trial with one of these counts
                nonnan1 = find(any((highCorr(:, ii) == locU')'), 1);
                slideBy = highCorr(nonnan1, ii);
                if nonnan1 > ii % reverse lower half of triangle
                    slideBy = -slideBy;
                end
                sigsAligned(:, ii) = [zeros(lAdd - slideBy, 1); sigs(:, ii); ...
                    zeros(rAdd + slideBy, 1)]; % slide by appropriate amount either left (slideBy < 0), right (slideBy > 0), or not at all (slideBy == 0)
            end
        end
    end
    
    ctr = ctr + lAdd; % move center by appropriate pre-padding amount

end

