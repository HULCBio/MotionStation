function d=dpurelin(n,a)
%DPURELIN Linear transfer derivative function.
%
%  Syntax
%
%    dA_dN = dpurelin(N,A)
%
%  Description
%
%    DPURELIN is the derivative function for LOGSIG.
%
%    DPURELIN(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 PURELIN
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with PURELIN and then
%    the derivative of A with respect to N.
%
%      A = purelin(N)
%      dA_dN = dpurelin(N,A)
%
%  Algorithm
%
%    The derivative of PURELIN is calculated as follows:
%
%      D(i,q) = 1
%
%  See also PURELIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = ones(size(n));
