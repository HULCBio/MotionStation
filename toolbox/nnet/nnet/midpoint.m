function [w,b] = midpoint(s,pr)
%MIDPOINT Midpoint weight initialization function.
%
%  Syntax
%
%    W = midpoint(S,PR)
%
%  Description
%
%    MIDPOINT is a weight initialization function that
%    sets weight (row) vectors to the center of the
%    input ranges.
%  
%  MIDPOINT(S,PR) takes two arguments,
%    S  - Number of rows (neurons).
%    PR - Rx2 matrix of input value ranges = [Pmin Pmax].
%  and returns an SxR matrix with rows set to (Pmin+Pmax)'/2.
%  
%  Examples
%
%    Here initial weight values are calculated for a 5 neuron
%    layer with input elements ranging over [0 1] and [-2 2].
%
%      W = midpoint(5,[0 1; -2 2])
%
%  Network Use
%
%    You can create a standard network that uses MIDPOINT to initialize
%    weights by calling NEWC.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to initialize with MIDPOINT:
%    1) Set NET.initFcn to 'initlay'.
%       (NET.initParam will automatically become INITLAY's default parameters.)
%    2) Set NET.layers{i}.initFcn to 'initwb'.
%    3) Set each NET.inputWeights{i,j}.initFcn to 'midpoint'.
%       Set each NET.layerWeights{i,j}.initFcn to 'midpoint';
%
%    To initialize the network call INIT.
%
%    See NEWC for initialization examples.
%
%  See also INITWB, INITLAY, INIT.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:31:29 $

if nargin < 2, error('Not enough arguments.'); end

% **[ NNT2 Support ]**
if size(pr,2) > 2
  nntobsu('midpoint','Use MIDPOINT(S,MINMAX(P)) instead of MIDPOINT(S,P).')
  pr = minmax(pr);
end

w = mean(pr,2)';
w = w(ones(1,s),:);

% **[ NNT2 Support ]**
if nargout == 2
  nntobsu('midpoint','Use B=ZEROS(S,1) instead of [W,B]=MIDPOINT(...).')
  b = zeros(s,1);
end
