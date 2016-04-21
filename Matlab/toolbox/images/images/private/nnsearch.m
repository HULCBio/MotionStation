function varargout = nnsearch(varargin)
%NNSEARCH Search optimized k-d tree for nearest neighbors.
%   [D,IDX] = NNSEARCH(TREE,TREE_POINTS,QUERY_POINTS) searches an
%   optimized k-d tree for nearest neighbors.  TREE is a kd-tree
%   constructed by KDTREE from TREE_POINTS, which is an N-by-M matrix of
%   M points in N-space.  (This is transposed from the normal convention
%   for efficient processing in the MEX-file.)  QUERY_POINTS is an N-by-P
%   matrix of P points in N-space.  For each of the P query points,
%   NNSEARCH determines the closest of the TREE_POINTS points, returns
%   that distance in the corresponding element of D, and returns the
%   index of the nearest point in the corresponding element of L.  D and
%   IDX are both P-by-1 vectors.
%
%   See also BWDIST, KDTREE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:11:23 $

%#mex

error('Images:nnsearch:missingMEXFile', 'Missing MEX-file: %s', mfilename);
