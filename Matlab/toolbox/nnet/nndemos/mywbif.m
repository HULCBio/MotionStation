function w = mywbif(s,pr)
%MYWBIF Example custom weight and bias initialization function.
%
%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    W = rands(S,PR)
%      S  - number of neurons.
%      PR - Rx2 matrix of R input ranges.
%      W - SxR weight matrix.
%
%    b = rands(S)
%      S  - number of neurons.
%      b - Sx1 bias vector.
%
%  Example
%
%    W = mywbif(4,[0 1; -2 2])
%    b = mywbif(4,[1 1])

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

if nargin < 1, error('Not enough input arguments'), end

if nargin == 1
  w = rand(s,1)*0.2;  % <-- Replace with your own initial bias vector
else
  r = size(pr,1);     % <-- Replace with your own initial weight matrix
  w = rand(s,r)*0.1;
end
