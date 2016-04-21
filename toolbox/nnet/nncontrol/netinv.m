function a = netinv(n,b)
%NETINV Inverse transfer function.
%  
%  Syntax
%
%    A = netinv(N)
%    info = netinv(code)
%
%  Description
%  
%    NETINV is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    NETINV(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns 1/N.
%  
%    NETINV(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here is the code to create a plot of the NETINV transfer function.
%  
%      n = -5:0.1:5;
%      a = netinv(n);
%      plot(n,a)
%
%  Network Use
%
%    To change a network so a layer uses NETINV, set
%    NET.layers{i}.transferFcn to 'netinv'.
%
%    In either case, call SIM to simulate the network with NETINV.
%
%  Algorithm
%
%      netinv(n) = 1/n
%
%  See also SIM, DNETINV, PURELIN, SATLIN, SATLINS.

% Orlando De Jesus, Martin Hagan, 8-8-99
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:12:10 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dnetinv';
    case 'name',
      a = 'Inverse';
    case 'output',
      a = [-inf +inf];
    case 'active',
      a = [-inf +inf];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'deltainv';
    nntobsu('netinv','Use NETINV(''deriv'') instead of NETINV(''delta'').')
    case 'init',
      a = 'rands';
    nntobsu('netinv','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('netinv','Use NETINV(NETSUM(Z,B*ones(1,Q))) instead of NETINV(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

a = 1./n;
