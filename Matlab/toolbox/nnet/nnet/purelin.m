function a = purelin(n,b)
%PURELIN Linear transfer function.
%  
%  Syntax
%
%    A = purelin(N)
%    info = purelin(code)
%
%  Description
%  
%    PURELIN is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    PURELIN(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns N.
%  
%    PURELIN(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here is the code to create a plot of the PURELIN transfer function.
%  
%      n = -5:0.1:5;
%      a = purelin(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses PURELIN
%    by calling NEWLIN or NEWLIND.
%
%    To change a network so a layer uses PURELIN, set
%    NET.layers{i}.transferFcn to 'purelin'.
%
%    In either case, call SIM to simulate the network with PURELIN.
%    See NEWLIN or NEWLIND for simulation examples.
%
%  Algorithm
%
%      purelin(n) = n
%
%  See also SIM, DPURELIN, SATLIN, SATLINS.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:34:44 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dpurelin';
    case 'name',
      a = 'Linear';
    case 'output',
      a = [-inf +inf];
    case 'active',
      a = [-inf +inf];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'deltalin';
    nntobsu('purelin','Use PURELIN(''deriv'') instead of PURELIN(''delta'').')
    case 'init',
      a = 'rands';
    nntobsu('purelin','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('purelin','Use PURELIN(NETSUM(Z,B*ones(1,Q))) instead of PURELIN(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

a = n;
