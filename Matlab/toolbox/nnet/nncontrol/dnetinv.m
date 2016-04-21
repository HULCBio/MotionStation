function d=dnetinv(n,a)
%DNETINV Inverse transfer derivative function.
%
%  Syntax
%
%    dA_dN = dnetinv(N,A)
%
%  Description
%
%    DNETINV is the derivative function for NETINV.
%
%    DNETINV(N,A) takes two arguments,
%      N - SxQ net input.
%      A - SxQ output.
%    and returns the SxQ derivative dA/dN.
%
%  Examples
%
%    Here we define the net input N for a layer of 3 NETINV
%    neurons.
%
%      N = [0.1; 0.8; -0.7];
%
%    We calculate the layer's output A with NETINV and then
%    the derivative of A with respect to N.
%
%      A = netinv(N)
%      dA_dN = dnetinv(N,A)
%
%  Algorithm
%
%    The derivative of NETINV is calculated as follows:
%
%      D(i,q) = -1/n^2
%
%  See also NETINV.

% Orlando De Jesus, Martin Hagan, 8-8-99
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:12:04 $

d = -1./(n.^2);
