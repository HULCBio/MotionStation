function [w,b] = initp(r,s)
%INITP Initialize perceptron layer.
%  
%  This function is obselete.
%  Use NNT2P and INIT to update and initialize your network.

nntobsf('initp','Use NNT2P and INIT to update and initialize your network.')

%  [W,B] = INITP(R,S)
%    R - Number of inputs to layer.
%    S - Number of neurons in layer.
%  Returns:
%    W - SxR Weight matrix.
%    B - Bias (column) vector.
%  
%  [W,B] = INITP(P,T)
%    P - RxQ matrix of input vectors.
%    T - SxQ matrix of target outputs.
%  Returns weights and biases.
%  
%  EXAMPLE: [w,b] = initp(2,3)
%           p = [0.5; -2];
%           a = simup(p,w,b)
%  
%  See also: NNINIT, PERCEPT, HARDLIM, SIMUP, LEARNP, TRAINP.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:11 $

if nargin < 2,error('Not enough arguments.'),end

% NUMBER OF INPUTS
[R,Q] = size(r);
if max(R,Q) > 1
  r = R;
end

% NUMBER OF NEURONS
[S,Q] = size(s);
if max(S,Q) > 1
  s = S;
end

[w,b] = rands(s,r);
