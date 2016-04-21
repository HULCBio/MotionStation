function tf = automesh(varargin)
%AUTOMESH True if the inputs should be automatically meshgridded.
%    AUTOMESH(X,Y) returns true if X and Y are vectors of
%    different orientations.
%
%    AUTOMESH(X,Y,Z) returns true if X,Y,Z are vectors of
%    different orientations.
%
%    AUTOMESH(...) returns true if all the inputs are vectors of
%    different orientations.

%   Copyright 1984-2002 The MathWorks, Inc.
%    $Revision: 1.8 $ $Date: 2002/04/15 04:24:15 $

for i=1:length(varargin)
  ns{i} = size(varargin{i})~=1; % Location of non-singleton dimensions
  isvec(i) = sum(ns{i})<=1;     % Is vector.
  nd(i) = ndims(varargin{i});    % Number of dimensions.
end

% True if inputs are 2-D, all vectors, and their non-singleton
% dimensions aren't along the same dimension.
tf = all(nd==2) & all(isvec) & ~isequal(ns{:});
