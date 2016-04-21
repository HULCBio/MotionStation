function d=dtribas(n,a)
%DTRIBAS Derivative of triangular basis transfer function.
%
%  Syntax
%
%    dA_dN = dtribas(N,A)
%
%  Description
%
%    DTRIBAS is the derivative function for TRIBAS.
%
%    DTRIBAS(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 TRIBAS
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with TRIBAS and then
%    the derivative of A with respect to N.
%
%      A = tribas(N)
%      dA_dN = dtribas(N,A)
%
%  Algorithm
%
%    The derivative of TRIBAS is calculated as follows:
%
%      d = 1, if -1 <= n < 0
%         -1, if 0 < n <= 1
%          0, otherwise
%
%  See also TRIBAS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = (abs(n) <= 1) .* sign(-n);
