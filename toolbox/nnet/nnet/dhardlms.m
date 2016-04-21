function d=dhardlms(n,a)
%DHARDLMS Derivative of symmetric hard limit transfer function.
%
%  Syntax
%
%    dA_dN = dhardlms(N,A)
%
%  Description
%
%    DHARDLMS is the derivative function for HARDLIMS.
%
%    DHARDLMS(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 HARDLIMS
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with HARDLIMS and then
%    the derivative of A with respect to N.
%
%      A = hardlims(N)
%      dA_dN = dhardlms(N,A)
%
%  Algorithm
%
%    The derivative of HARDLIMS is calculated as follows:
%
%      d = 0
%
%  See also HARDLIMS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = zeros(size(n));
