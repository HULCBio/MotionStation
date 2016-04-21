function d=dradbas(n,a)
%DRADBAS Derivative of radial basis transfer function.
%
%  Syntax
%
%    dA_dN = dradbas(N,A)
%
%  Description
%
%    DRADBAS is the derivative function for RADBAS.
%
%    DRADBAS(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 RADBAS
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with RADBAS and then
%    the derivative of A with respect to N.
%
%      A = radbas(N)
%      dA_dN = dradbas(N,A)
%
%  Algorithm
%
%    The derivative of RADBAS is calculated as follows:
%
%      d = -2*n*a
%
%  See also RADBAS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = (-2)*(n.*a);
