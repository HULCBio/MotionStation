function [a1,a2] = simulvq(p,w1,w2)
%SIMULVQ Simulate LVQ network.
%  
%  This function is obselete.
%  Use NNT2LVQ and SIM to update and simulate your network.

nntobsf('simulvq','Use NNT2LVQ and SIM to update and simulate your network.')

%  SIMULVQ(P,W1,W2)
%    P  - Matrix of input (column) vectors.
%    W1 - S1xR weight matrix for competitive hidden layer.
%    W2 - S2xS1 weight matrix for linear output layer.
%  Returns output of the linear output layer.
%  
%  [A1,A2] = SIMUFF(P,W1,W2)
%  Returns:
%    A1 - Output of the competitive hidden layer.
%    A2 - Output of the linear output layer.
%  
%  EXAMPLE: P = [-1 2 3 2 -2 1 0; 2 -1 1 -3 1 -2 2];
%           T = [0 0 0 1 1 1 1; 1 1 1 0 0 0 0];
%           [W1,W2] = initlvq(P,7,T);
%           p = [1; -1];
%           a = simulvq(p,W1,W2)
%  
%  See also NNSIM, LVQ, INITLVQ, TRAINLVQ.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:57 $

if nargin < 3,error('Not enough input arguments'),end

if nargout <= 1
  a1 = w2*compet(-dist(w1,p));
else
  a1 = compet(-dist(w1,p));
  a2 = w2*a1;
end
