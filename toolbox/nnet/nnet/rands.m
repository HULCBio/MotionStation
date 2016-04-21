function [w,b] = rands(s,pr)
%RANDS Symmetric random weight/bias initialization function.
%
%  Syntax
%
%    W = rands(S,PR)
%    M = rands(S,R)
%    v = rands(S);
%
%  Description
%
%    RANDS is a weight/bias initialization function.
%
%    RANDS(S,PR) takes,
%      S  - number of neurons.
%      PR - Rx2 matrix of R input ranges.
%    and returns an S-by-R weight matrix of random values between -1 and 1.
%
%    RANDS(S,R) returns an S-by-R matrix of random values.
%    RANDS(S) returns an S-by-1 vector of random values.
%
%  Examples
%
%    Here three sets of random values are generated with RANDS.
%
%      rands(4,[0 1; -2 2])
%      rands(4)
%      rands(2,3)
%
%  Network Use
%
%    To prepare the weights and the bias of layer i of a custom network
%    to be initialized with RANDS:
%    1) Set NET.initFcn to 'initlay'.
%       (NET.initParam will automatically become INITLAY's default parameters.)
%    2) Set NET.layers{i}.initFcn to 'initwb'.
%    3) Set each NET.inputWeights{i,j}.initFcn to 'rands'.
%       Set each NET.layerWeights{i,j}.initFcn to 'rands';
%       Set each NET.biases{i}.initFcn to 'rands'.
%
%    To initialize the network call INIT.
%
%  See also RANDNR, RANDNC, INITWB, INITLAY, INIT

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:38 $

if nargin < 1, error('Not enough input arguments.'); end

if nargin == 1
  r = 1;
elseif size(pr,2) == 1
  r = pr;
else
  r = size(pr,1);
end
w = 2*rand(s,r)-1;

% **[ NNT2 Support ]**
if nargout == 2
  b = 2*rand(s,1)-1;
end
