function z = zscore(x)
%ZSCORE Standardized z score.
%   Z = ZSCORE(X) returns a centered, scaled version of X, known as the Z
%   scores of X.  For a vector input, Z = (X - MEAN(X)) ./ STD(X).  For a
%   matrix input, Z is a row vector containing the Z scores of each column
%   of X.  For N-D arrays, ZSCORE operates along the first non-singleton
%   dimension.
%
%   Z has sample mean zero and sample standard deviation one.  ZSCORE is
%   commonly used to preprocess data before computing distances for cluster
%   analysis.
%
%   See also MEAN, VAR, PDIST, CLUSTER, CLUSTERDATA.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.2 $  $Date: 2004/01/24 09:37:27 $

% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

% Figure out which dimension sum will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim), dim = 1; end

% Need to tile the output of mean and std to standardize X.
tile = ones(1,ndims(x)); tile(dim) = sz(dim);

% Compute X's mean and sd, and standardize it.
warn = warning('off','MATLAB:divideByZero');
xbar = repmat(mean(x), tile);
sd = repmat(std(x), tile);
warning(warn)
sd(sd==0) = 1; % don't try to scale constant columns
z = (x - xbar) ./ sd;
