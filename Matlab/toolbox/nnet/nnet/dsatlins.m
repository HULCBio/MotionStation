function d=dsatlins(n,a)
%DSATLINS Derivative of symmetric saturating linear transfer function.
%
%  Syntax
%
%    dA_dN = dsatlins(N,A)
%
%  Description
%
%    DSATLINS is the derivative function for SATLINS.
%
%    DSATLINS(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 SATLINS
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with SATLINS and then
%    the derivative of A with respect to N.
%
%      A = satlins(N)
%      dA_dN = dsatlins(N,A)
%
%  Algorithm
%
%    The derivative of SATLINS is calculated as follows:
%
%      d = 1, if -1 <= n <= 1
%          0, otherwise
%
%  See also SATLINS.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = (n >= -1) & (n <= 1);

