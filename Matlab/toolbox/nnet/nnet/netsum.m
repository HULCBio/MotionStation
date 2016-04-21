function n=netsum(varargin)
%NETSUM Sum net input function.
%
%  Syntax
%
%    N = netsum(Z1,Z2,...)
%    df = netsum('deriv')
%
%  Description
%
%    NETSUM is a net input function.  Net input functions
%    calculate a layer's net input by combining its weighted
%    inputs and biases.
%
%    NETSUM(Z1,Z2,...,Zn) takes any number of inputs,
%      Zi - SxQ matrices.
%    and the returns N the element-wise sum of Zi's.
%
%    NETSUM('deriv') returns NETSUM's derivative function.
%
%  Examples
%
%    Here NETSUM combines two sets of weighted input
%    vectors (which we have defined ourselves).
%
%      z1 = [1 2 4;3 4 1];
%      z2 = [-1 2 2; -5 -6 1];
%      n = netsum(z1,z2)
%
%    Here NETSUM combines the same weighted inputs with
%    a bias vector.  Because Z1 and Z2 each contain three
%    concurrent vectors, three concurrent copies of B must
%    be created with CONCUR so that all sizes match up.
%
%      b = [0; -1];
%      n = netsum(z1,z2,concur(b,3))
%
%  Network Use
%
%    You can create a standard network that uses NETSUM
%    by calling NEWP or NEWLIN.
%
%    To change a network so a layer uses NETSUM, set
%    NET.layers{i}.netInputFcn to 'netsum'.
%
%    In either case, call SIM to simulate the network with NETSUM.
%    See NEWP or NEWLIN for simulation examples.
%
%  See also NETWORK/SIM, DNETSUM, NETPROD, CONCUR

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

n = varargin{1};

% FUNCTION INFO
if isstr(n)
  switch n
    case 'deriv',
      n = 'dnetsum';
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
for i=2:length(varargin)
  n = n + varargin{i};
end
