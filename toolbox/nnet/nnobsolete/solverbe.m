function [w1,b1,w2,b2] = solverbe(p,t,z)
%SOLVERBE Design exact radial basis network.
%  
%  This function is obselete.
%  Use NEWRBE to design your network.

nntobsf('solverbe','Use NEWRBE to design your network.')

%  [W1,B1,W2,B2] = SOLVERBE(P,T,Z)
%    P - RxQ matrix of Q input vectors.
%    T - SxQ matrix of Q target vectors.
%    Z - Spread of radial basis functions (default = 1).
%  Returns:
%    W1 - S1xR weight matrix for radial basis layer.
%    B1 - S1x1 bias vector for radial basis layer.
%    W2 - S2xS1 weight matrix for linear layer.
%    B2 - S2x1 bias vector for linear layer.
%  
%  SOLVERBE creates a radial basis network which performs
%   an exact mapping of input to outputs with as many
%   hidden neurons as their are input vectors in P.
%  
%  See also NNSOLVE, RADBASIS, SIMRB, SOLVERB

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:47 $

[r,q] = size(p);
[s2,q] = size(t);

w1 = p';
b1 = ones(q,1)*sqrt(-log(.5))/z;
a1 = radbas(dist(w1,p),b1);
[w2,b2] = solvelin(a1,t);
