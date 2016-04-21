function [numOutports, flatVectorOfLengths, flatVectorOfIndices] = dspblkmultiportsel(cellArrayToParse)
% DSPBLKMULTIPORTSEL Mask helper function for Multi-port Selector block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:59:10 $ $Revision: 1.6 $

% Cache the block handle once:
blk = gcb;

% Default outputs for a badly-formatted input
numOutports         = 1;
flatVectorOfLengths = [];
flatVectorOfIndices = [];

if isInputProperlyFormattedCellArray(cellArrayToParse),
    % ---------------------------------------------------------------
    % The cell array is already a properly-formatted 1-D cell array.
    %
    % Need to take this cell array and return TWO flattened vectors:
    %
    % 1) A vector of LENGTHS for each vector entry in the cell array
    % 2) A flattened vector of INDICES from the cell array values
    %
    % For example, the cell array { 4, [1:2 5], [7; 8], 10:-1:6}
    %
    % contains 4 vectors (cells) of indices of lengths
    % 1, 3, 2, and 5, respectively.  This particular cell array
    % should thus be flattened as follows:
    %
    % flatVectorOfLengths = [1 3 2 5];
    % flatVectorOfIndices = [4 1 2 5 7 8 10 9 8 7 6];
    % ---------------------------------------------------------------
    
    % First arrange each cell (vector) into separate rows
    cellArrayToParse = cellArrayToParse(:);
    numOutports      = size(cellArrayToParse,1);

    for i = 1:numOutports,
        len = length(cellArrayToParse{i});
        temp = reshape(cellArrayToParse{i},1,len);

        flatVectorOfIndices = [flatVectorOfIndices temp];
        flatVectorOfLengths = [flatVectorOfLengths len];
    end
elseif isInputMatlabVector(cellArrayToParse),
    % ---------------------------------------------------------------
    % The "cell array" is really just a vector...
    % ---------------------------------------------------------------
    numOutports         = 1;
    flatVectorOfIndices = cellArrayToParse(:);
    flatVectorOfLengths = [ length(flatVectorOfIndices) ];
end

% ------------
% SUBFUNCTIONS
% ------------

function y = isInputProperlyFormattedCellArray(u)
    y = (isa(u,'cell') & ( isequal(size(u,1),1) | isequal(size(u,2),1) ));

function y = isInputMatlabVector(u)
    len = length(u);
    y = (isequal(size(u,1), len) & isequal(size(u,2), 1)) | (isequal(size(u,1), 1) & isequal(size(u,2), len));

% [EOF] dspblkmultiportsel.m
