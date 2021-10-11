function [template,templateArrayCell, maxIdxArray] = template_equalize_length(templateCell,rawSig,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;

addRequired(p,'templateCell',@iscell);
addRequired(p,'rawSig',@isnumeric);

addParameter(p,'goodCell', {}, @iscell);
addParameter(p,'startInds',[],@iscell);
addParameter(p,'lengthMax',25,@isnumeric);

p.parse(templateCell,rawSig,varargin{:});
templateCell = p.Results.templateCell;
rawSig = p.Results.rawSig;
startInds = p.Results.startInds;
lengthMax = p.Results.lengthMax;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

template = repmat({cell(1, length(startInds))}, 1, size(rawSig, 2));
maxIdx = repmat({cell(1, length(startInds))}, 1, size(rawSig, 2));

for chan = 1:size(rawSig, 2)
    
    lengthMaxChan = lengthMax(chan);
    
    for trial = 1:length(startInds)
        artifactsMat = nan(lengthMaxChan, length(startInds{trial}{chan}));
            for sts = 1:length(startInds{trial}{chan})
                artifactsTrial = templateCell{chan}{trial}{sts};
                if length(artifactsTrial) < lengthMaxChan
                    amntPad = lengthMaxChan - length(artifactsTrial);
                    artifactsMat(:, sts) = padarray(artifactsTrial, amntPad, 0, 'post');
                else
                    artifactsMat(:, sts) = artifactsTrial;
                end
            end
        template{chan}{trial} = artifactsMat;
        % find the index of the overall maximum
        [~, maxIdx{chan}{trial}] = max(artifactsMat, [], 1);

    end
    
end


templateArrayCell = cellfun(@(x) [x{:}], template, 'UniformOutput', false);
maxIdxArray = cellfun(@(x) [x{:}], maxIdx, 'UniformOutput', false);

fprintf(['-------Finished making artifacts the same length-------- \n'])

end