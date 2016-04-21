function a = satlins(n,b)
%SATLINS Symmetric saturating linear transfer function.
%  
%  Syntax
%
%    A = satlins(N)
%    info = satlins(code)
%
%  Description
%  
%    SATLINS is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    SATLINS(N)  takes one input,
%      N - SxQ Matrix of net input (column) vectors.
%    and returns values of N truncated into the interval [-1, 1].
%  
%  
%    SATLINS(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here is the code to create a plot of the SATLINS transfer function.
%  
%      n = -5:0.1:5;
%      a = satlins(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses SATLINS
%    by calling NEWHOP.
%
%    To change a network so that a layer uses SATLINS, set
%    NET.layers{i}.transferFcn to 'satlins'.
%
%    In either case, call SIM to simulate the network with SATLINS.
%    See NEWHOP for simulation examples.
%
%  Algorithm
%
%      satlins(n) = -1, if n <= -1
%                    n, if -1 <= n <= 1
%                    1, if 1 <= n
%
%  See also SIM, SATLIN, POSLIN, PURELIN.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:34:41 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dsatlins';
    case 'name',
      a = 'Symmetric Saturating Linear';
    case 'output',
      a = [-1 1];
    case 'active',
      a = [-1 1];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'none';
    nntobsu('satlins','Use SATLINS(''deriv'') instead of SATLINS(''delta'').')
    case 'init',
      a = 'rands';
    nntobsu('satlins','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('satlins','Use SATLINS(NETSUM(Z,B)) instead of SATLINS(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

a = max(-1,min(1,n));
