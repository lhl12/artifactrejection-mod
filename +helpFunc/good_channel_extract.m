function [goods,goodCell, allGood] = good_channel_extract(varargin)
% Usage:  [goods,goodVec] = good_channel_extract(varargin)
%
% This function will perform an interpolation scheme for artifacts on a
% trial by trial, channel by channel basis, implementing either a linear
% interpolation scheme, or a pchip interpolation scheme
%
% MOD LHL: accomodate different stim channels for each trial
% 
% Arguments:
%   Required:
%        numChans - Number of channels recorded from, including stimulation
%        and bad channels
%
%   Optional:
%   bads - trials x channels
%
%   stimChans - channels used for stimulation which should be trials x 2
%
% Returns:
%   goods - a logical matrix with 0 being the "bad" channels, and 1 being
%   good channels (e.g. [1 0 0 1]
%   goodCell - trials x 1 cell array with good channels for each trial  in
%   each cell
%   allGood - vector of channels that are never bad or used for stimulation
%
%
%
% Copyright (c) 2018 Updated by David Caldwell
% University of Washington
% djcald at uw . edu 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;

addParameter(p,'numChans',64,@isnumeric);
addParameter(p,'bads',[],@(x) isnumeric(x) || islogical(x));
addParameter(p,'stimChans',[],@isnumeric);
p.parse(varargin{:});

bads = p.Results.bads;
stimChans = p.Results.stimChans;
numChans = p.Results.numChans;

if isempty(bads)
    
elseif size(stimChans, 1) ~= size(bads, 1)
    error('stimChans should be trials x 2 (annode cathode), bads should be a logical array of trials x channels or a cell array of trials x 1');
end

numTrials = size(stimChans, 1);

% make logical good channels matrix to index
goods = true(numTrials, numChans);
goodCell = cell(numTrials, 1);

% set the goods matrix to be zero where bad channels are
for trl = 1:numTrials
    goods(trl, stimChans(trl, :)) = false;
    if isempty(bads)

    elseif iscell(bads)
        goods(trl, bads{trl}) = false;
    elseif islogical(bads)
        goods(trl, bads(trl, :)) = false;
    else
        warning('Unrecognized data type for bads (must be a logical array of trials x channels or a cell array of trials x 1');
    end
    goodCell{trl} = find(goods(trl, :));
end

allGood = find(all(goods, 1))';

end

