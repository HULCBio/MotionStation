function v = nngenc(x,c,n,d)
%NNGENC Generate clusters of data points.
%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNGENC(X,C,N,D)
%   X - Rx2 matrix of cluster bounds.
%   C - Number of clusters.
%   N - Number of data points in each cluster.
%   D - Standard deviation of clusters, default = 1.
% Returns a matrix containing C*N R-element vectors arranged
%   in C clusters with centers inside bounds set by X, with
%   N elements each, randomly around the centers with
%   standard deviation of D.
%
% Each ith row of X must contain the minimum and maximum
%   values for the ith dimension of a cluster center.
%
% EXAMPLE: X = [-10 10; -5 5];
%          V = nngenc(X,8,6,0.5);
%          plot(V(1,:),V(2,:),'+')

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $  $Date: 2002/04/14 21:26:12 $

if nargin < 3, error('Not enough arguments.'), end
if nargin == 3, d = 1; end

[r,q] = size(x);
minv = min(x')';
maxv = max(x')';
v = rand(r,c) .* ((maxv-minv) * ones(1,c)) + (minv * ones(1,c));
t = c*n;
v = nncopy(v,1,n) + randn(r,t)*d;
