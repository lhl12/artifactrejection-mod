function [templateCell,lengthMax,maxAmps,maxLocation] = get_artifacts(rawSig,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;

validData = @(x) isnumeric(x);
addRequired(p,'rawSig',validData);
addParameter(p,'plotIt',0,@(x) x==0 || x ==1);
addParameter(p,'goodCell',[1:64],@iscell);
addParameter(p,'startInds',[],@iscell);
addParameter(p,'endInds',[],@iscell);
addParameter(p,'normalize','firstSamp',@isstr);
addParameter(p,'amntPreAverage',3,@isnumeric)

p.parse(rawSig,varargin{:});
rawSig = p.Results.rawSig;
plotIt = p.Results.plotIt;
startInds = p.Results.startInds;
endInds = p.Results.endInds;
goodCell = p.Results.goodCell;
normalize = p.Results.normalize;
amntPreAverage = p.Results.amntPreAverage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nTrials = length(startInds); nChans = size(rawSig, 2);

lengthMaxVecTrial = zeros(nTrials, nChans);
maxLocationTrials = nan(nTrials, nChans);
maxTrials = nan(nTrials, nChans);
templateCell = repmat({cell(1, nTrials)}, 1, nChans);

for trial = 1:nTrials % loop through trials
    
    lengthMaxChan = zeros(1, nChans);

    for chan = goodCell{trial} % loop through good channels for this trial
        
        locMax = zeros(1, length(startInds{trial}{chan}));
        avgSignal = cell(1, length(startInds{trial}{chan}));
        for sts = 1:length(startInds{trial}{chan}) % loop through individual stimulation epochs
            win = startInds{trial}{chan}(sts):endInds{trial}{chan}(sts);
            locMax(sts) = length(win);
            
            rawSigTemp = rawSig(win, chan);
            
            switch normalize
                case 'preAverage'
                    avgSignal{sts} = rawSigTemp - mean(rawSigTemp(1:amntPreAverage));% take off average of first x samples
                case 'none'
                    avgSignal{sts} = rawSigTemp;
                case 'firstSamp'
                    avgSignal{sts} = rawSigTemp - rawSigTemp(1);
                case 'mean'
                    avgSignal{sts} = rawSigTemp - mean(rawSigTemp);
                    
            end
                        
        end
        
        if isempty(locMax)
            lengthMaxChan(chan) = 0;
            maxLocationTrials(trial, chan) = 0;
            maxTrials(trial, chan) = 0;
        else
            lengthMaxChan(chan) = max(locMax);
            templateCell{chan}{trial} = avgSignal;

            [maxLoc, idxLoc] = cellfun(@max, avgSignal);
            maxLocationTrials(trial, chan) = median(idxLoc);
            maxTrials(trial, chan) = median(maxLoc);
        end
        
        if plotIt && (trial == 10 || trial == 1000)
            figure
            plot(rawSigTemp,'linewidth',2)
            vline(startInds{trial})
            vline(endInds{trial},'g')
        end
        
    end
    lengthMaxVecTrial(trial,:) = lengthMaxChan;
    
end

% figure out the maximum amplitude artifact for each given channel and
% trial

% find maximum index for reducing dimensionality later
[maxAmps, idxMaxTrial] = nanmax(maxTrials); % maximum amplitude for each trial
[~, maxChan] = max(maxAmps); % the channel with the maximal value in the artifact
maxLocation = maxLocationTrials(idxMaxTrial(maxChan), maxChan); % the index of maxAmps in the maximal trial

% get the maximum length of any given artifact window for each channel
lengthMax = max(lengthMaxVecTrial,[],1);

end