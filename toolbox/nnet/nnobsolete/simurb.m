function [a1,a2] = simurb(p,w1,b1,w2,b2)
%SIMURB Simulate radial basis network.
%  
%  This function is obselete.
%  Use NNT2RB and SIM to update and simulate your network.

nntobsf('simurb','Use NNT2RB and SIM to update and simulate your network.')

%  SIMURB(P,W1,B1,W2,B2)
%    P  - Matrix of input (column) vectors.
%    W1 - Weight matrix of radial basis layer.
%    B1 - Bias vector of radial basis layer.
%    W2 - Weight matrix of linear output layer.
%    B2 - Bias vector of linear output layer.
%  Returns outputs of the linear output layer.
%  
%  [A1,A2] = SIMURB(P,W1,B1,W2,B2)
%  Returns:
%    A1 - Outputs of the radial basis layer.
%    A2 - Outputs of the linear layer.
%  
%  EXAMPLE: p = [0 1 2 3 4 5 6];
%           t = [1 2 3 3 2 1 1];
%           [w1,b1,w2,b2] = solverb(p,t);
%           p = 2.5;
%           a = simurb(p,w1,b1,w2,b2)
%  
%  See also NNSIM, RADBASIS, SOLVERB, SOLVERBE.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:16:03 $

if nargin < 5, error('Not enough input arguments'),end

if nargout <= 1
  a1 = purelin(w2*radbas(dist(w1,p),b1),b2);
else
  a1 = radbas(dist(w1,p),b1);
  a2 = purelin(w2*a1,b2);
end
