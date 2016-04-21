function d=dhardlim(n,a)
%DHARDLIM Derivative of hard limit transfer function.
%
%  Syntax
%
%    dA_dN = dhardlim(N,A)
%
%  Description
%
%    DHARDLIM is the derivative function for HARDLIM.
%
%    DHARDLIM(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 HARDLIM
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with HARDLIM and then
%    the derivative of A with respect to N.
%
%      A = hardlim(N)
%      dA_dN = dhardlim(N,A)
%
%  Algorithm
%
%    The derivative of HARDLIM is calculated as follows:
%
%      d = 0
%
%  See also HARDLIM.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = zeros(size(n));
