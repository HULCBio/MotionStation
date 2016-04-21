function d=dsatlin(n,a)
%DSATLIN Derivative of saturating linear transfer function.
%
%  Syntax
%
%    dA_dN = dsatlin(N,A)
%
%  Description
%
%    DSATLIN is the derivative function for SATLIN.
%
%    DSATLIN(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 SATLIN
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with SATLIN and then
%    the derivative of A with respect to N.
%
%      A = satlin(N)
%      dA_dN = dsatlin(N,A)
%
%  Algorithm
%
%    The derivative of SATLIN is calculated as follows:
%
%      d = 1, if 0 <= n <= 1
%          0, otherwise
%
%  See also SATLIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = (n >= 0) & (n <= 1);
