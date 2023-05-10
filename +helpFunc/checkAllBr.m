function [datout] = checkAllBr(data, fsData, anode, cathode, onsets_samps, varargin)
%CHECKALLBR Summary of this function goes here
%   Detailed explanation goes here

    p = inputParser;
    addRequired(p, 'data', @isnumeric);
    addRequired(p, 'fsData', @isnumeric);
    addRequired(p, 'anode', @isnumeric);
    addRequired(p, 'cathode', @isnumeric);
    addRequired(p, 'onsets_samps', @isnumeric);
    addParameter(p, 'dmdb', 'eucl', @(x) strcmp(x, 'eucl') || strcmp(x, 'corr'));
    addParameter(p, 'pre', .4096, @isnumeric);
    addParameter(p, 'post', .4096, @isnumeric);
    
    p.parse(data, fsData, anode, cathode, onsets_samps, varargin{:});
    
    data = p.Results.data;
    fsData = p.Results.fsData;
    anode = p.Results.anode;
    cathode = p.Results.cathode;
    onsets_samps = p.Results.onsets_samps;
    dmdb = p.Results.dmdb;
    pre = p.Results.pre;
    post = p.Results.post;
    
    br = {{-6:6 -6:5 -6:4 -6:3 -6:2 -6:1 -1:6 -2:6 -3:6 -4:6 -5:6}, ...
        {-5:5 -5:4 -5:3 -5:2 -5:1 -1:5 -2:5 -3:5 -4:5}, ...
        {-4:4 -4:3 -4:2 -4:1 -1:4 -2:4 -3:4}, ...
        {-3:3 -3:2 -3:1 -1:3 -2:3}, {-2:2 -2:1 -1:2}};
    dims = [4 3; 3 3; 3 3; 2 3; 1 3];
    
    datout = cell(size(br));
    
    for b1 = 1:length(br)
        figure;
        loc = cell(1, length(br{b1}));
        for b2 = 1:length(br{b1})
            subplot(dims(b1, 1), dims(b1, 2), b2);
%             figure;
            
%             plot(data, 'r');
%             hold on;
            [da, ~, ~, ~, ~, chck] = analyFunc.template_subtract(data, 'fs', ...
                fsData, 'stimChans', [anode cathode], 'stimRecord', onsets_samps, ...
                'bracketRange', br{b1}{b2}, 'distanceMetricDbscan', dmdb, ...
                'pre', pre, 'post', post);%'threshVoltageCut', 90, 'threshDiffCut', 90, ...
                %'useProcrustes', 1);%, 'distanceMetricDbscan', 'corr');
%             di = interpSpikes(da, 99, onsets_samps, 50, [annode cathode]);
            
%             a = max(abs(da));
%             b = bar(a);
%             s = sum(a > 0.005);
%             b.CData(a > 0.005, :) = repmat([0.5 0 0.5], s, 1);      
%             loc{b2} = a;
%             title([num2str(br{b1}{b2}(1)) ':' num2str(br{b1}{b2}(end)) ', ' num2str(s) ' bad chans']);

%             ch = [1:6 9:16];
%             ch = 1;
            
%             for ii = 1:length(annode)
%                 subplot(1, 5, ii)
%                 plot(da(onsets_samps(ii) - 100:onsets_samps(ii) + 200));
%             end

%             plot(da(:, ch)); 
%             hold on; plot(di);

%             plot(da(:, 1:6));
            plot(da);

            
            title([num2str(br{b1}{b2}(1)) ':' num2str(br{b1}{b2}(end)) ' (' num2str(nansum(chck)) ')']);
            
            vline(onsets_samps);
            if all(nansum(chck) >= .8*size(chck, 1))
%             if all(nansum(chck) == size(chck, 1))
                return
            end

            
        end
        
        datout{b1} = loc;
    end

end

