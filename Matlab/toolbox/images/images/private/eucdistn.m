function [D,L] = eucdistn(BW)
%EUCDISTN N-D Euclidean distance transform.
%   D = EUCDISTN(BW) computes the Euclidean distance transform on the input 
%   binary image BW, which can have any dimension.  Specifically, it
%   computes the distance to the nearest nonzero-valued pixel.
%    
%   [D,L] = EUCDIST2(BW) returns a linear index array L representing a
%   nearest-neighbor transform.
%
%   See also BWDIST.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/01/26 05:59:27 $

% L is a double-precision array with the same size as BW and D, so only
% compute it if the caller asked for it.
do_labels = nargout > 1;

size_BW = size(BW);
D = zeros(size(BW));

% Optimization: zero-valued elements of BW can be closest only to
% one-valued elements that belong to the perimeter of BW.  By reducing
% the number of one-valued points to be searched, we can cut down on the
% search time.
perim = bwperim(BW,conndef(ndims(BW),'maximal'));

% Find the locations of the perimeter pixels and convert that into an
% M-by-N array perim_subs containing the locations of M points in
% N-space.
perim_idx = find(perim);
perim_subs = cell(1,ndims(BW));
[perim_subs{:}] = ind2sub(size_BW, perim_idx);
perim_subs = [perim_subs{:}];

% Find the locations of the zero-valued pixels and convert that into a
% P-by-N array bg_subs containing the the locations of P points in
% N-space.
bg_idx = find(~BW);
bg_subs = cell(1,ndims(BW));
[bg_subs{:}] = ind2sub(size_BW, bg_idx);
bg_subs = [bg_subs{:}];

% From perim_subs, construct an optimized k-d tree with a bucket size of
% 25.
tree = kdtree(perim_subs,25);

% Using the k-d tree, find the closest one-valued pixel for each
% zero-valued pixel.
[dist,idx] = nnsearch(tree,perim_subs',bg_subs');
D(bg_idx) = dist;

if do_labels
    % Compute the nearest-neighbor transform.  We have all the
    % information necessary, but it takes a bit of indexing magic to
    % construct it.
    L = zeros(size(BW));
    bw_idx = find(BW);
    if length(bw_idx) > 0
        L(bw_idx) = bw_idx;
        Lp = L(perim);
        L(bg_idx) = Lp(idx);
    else
        % There were no one-valued points in BW, so leave
        % L all zeros.  Nothing to do here.
    end
end

