function [offsets,heights] = getneighbors(se)
%GETNEIGHBORS Get structuring element neighbor locations and heights.
%   [OFFSETS,HEIGHTS] = GETNEIGHBORS(SE) returns the relative locations
%   and corresponding heights for each of the neighbors in the
%   structuring element object SE.  OFFSETS is a P-by-N array where P is
%   the number of neighbors in the structuring element and N is the
%   dimensionality of the structuring element.  Each row of OFFSETS
%   contains the location of the corresponding neighbor, relative to the
%   center of the structuring element.  HEIGHTS is a P-element column
%   vector containing the height of each structuring element neighbor.
%
%   Example
%   -------
%       se = strel([1 0 1],[5 0 -5])
%       [offsets,heights] = getneighbors(se)
%
%   See also STREL, STREL/GETNHOOD, STREL/GETHEIGHT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:09:44 $

% Testing notes
% Syntaxes
% --------
% [OFFSETS,HEIGHTS] = GETNEIGHBORS(SE)
%
% se:      a 1-by-1 strel array
% 
% offsets: a num_neighbors-by-num_dims array containing the relative
%          offsets of each neighbor relative to the center of the
%          neighborhood.
%
% heights: a num_neighbors-by-1 column vector of containing the height
%          corresponding to each neighbor.

if length(se) ~= 1
    error('Images:getneighbors:wrongType', 'SE must be a 1-by-1 STREL array.');
end

num_dims = ndims(se.nhood);
idx = find(se.nhood);
heights = se.height(idx);
size_nhood = size(se.nhood);
center = floor((size_nhood+1)/2);
subs = cell(1,num_dims);
[subs{:}] = ind2sub(size_nhood,idx);
offsets = [subs{:}];
offsets = reshape(offsets,length(idx),num_dims);
offsets = offsets - repmat(center, size(offsets,1), 1);

