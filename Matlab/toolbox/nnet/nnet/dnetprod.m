function d=dnetprod(z,n)
%DNETPROD Derivative of net input product function.
%
%   Syntax
%
%    dN_dZ = dnetprod(Z,N)
%
%  Description
%
%    DNETPROD is the net input derivative function for NETPROD.
%
%    DNETPROD takes two arguments,
%      Z - SxQ weighted input.
%      N - SxQ net input.
%    and returns the SxQ derivative dN/dZ.
%
%  Examples
%
%    Here we define two weighted inputs for a layer with
%    three neurons.
%
%      Z1 = [0.1; 1; -1];
%      Z2 = [1; 0.5; 1.2];
%
%    We calculate the layer's net input N with NETPROD and then
%    the derivative of N with respect to each weighted input.
%
%      N = netprod(Z1,Z2)
%      dN_dZ1 = dnetprod(Z1,N)
%      dN_dZ2 = dnetprod(Z2,N)
%
%  Algorithm
%
%    The derivative a product with respect to any element of that
%    product is the product of the other elements.
%
%  See also NETSUM, NETPROD, DNETSUM.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

d = n./z;
