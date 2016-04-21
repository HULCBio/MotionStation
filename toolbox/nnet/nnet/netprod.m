function n=netprod(varargin)
%NETPROD Product net input function.
%
%  Syntax
%
%    N = netprod(Z1,Z2,...)
%    df = netprod('deriv')
%
%  Description
%
%    NETPROD is a net input function.  Net input functions
%    calculate a layer's net input by combining its weighted
%    inputs and biases.
%
%    NETPROD(Z1,Z2,...,Zn)
%      Zi - SxQ matrices.
%    Returns element-wise sum of Zi's.
%
%    NETPROD('deriv') returns NETPROD's derivative function.
%
%  Examples
%
%    Here NETPROD combines two sets of weighted input
%    vectors (which we have defined ourselves).
%
%      z1 = [1 2 4;3 4 1];
%      z2 = [-1 2 2; -5 -6 1];
%      n = netprod(z1,z2)
%
%    Here NETPROD combines the same weighted inputs with
%    a bias vector.  Because Z1 and Z2 each contain three
%    concurrent vectors, three concurrent copies of B must
%    be created with CONCUR so that all sizes match up.
%
%      b = [0; -1];
%      n = netprod(z1,z2,concur(b,3))
%
%  Network Use
%
%    You can create a standard network that uses NETPROD
%    by calling NEWPNN or NEWGRNN.
%
%    To change a network so that a layer uses NETPROD, set
%    NET.layers{i}.netInputFcn to 'netprod'.
%
%    In either case, call SIM to simulate the network with NETPROD.
%    See NEWPNN or NEWGRNN for simulation examples.
%
%  See also NETWORK/SIM, DNETPROD, NETSUM, CONCUR

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

n = varargin{1};

% FUNCTION INFO
if isstr(n)
  switch n
    case 'deriv',
      n = 'dnetprod';
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
for i=2:length(varargin)
  n = n .* varargin{i};
end
