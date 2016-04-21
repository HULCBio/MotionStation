function d=dlogsig(n,a)
%DLOGSIG Log sigmoid transfer derivative function.
%
%  Syntax
%
%    dA_dN = dlogsig(N,A)
%
%  Description
%
%    DLOGSIG is the derivative function for LOGSIG.
%
%    DLOGSIG(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 TANSIG
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with LOGSIG and then
%    the derivative of A with respect to N.
%
%      A = logsig(N)
%      dA_dN = dlogsig(N,A)
%
%  Algorithm
%
%    The derivative of LOGSIG is calculated as follows:
%
%      d = a * (1 - a)
%
%  See also LOGSIG, TANSIG, DTANSIG.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

d = a.*(1-a);
