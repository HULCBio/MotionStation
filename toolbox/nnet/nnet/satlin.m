function a = satlin(n,b)
%SATLIN Saturating linear transfer function.
%  
%  Syntax
%
%    A = satlin(N)
%    info = satlin(code)
%
%  Description
%  
%    SATLIN is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    SATLIN(N)  takes one input,
%      N - SxQ Matrix of net input (column) vectors.
%    and returns values of N truncated into the interval [-1, 1].
%  
%  
%    SATLIN(CODE) return useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here is the code to create a plot of the SATLIN transfer function.
%  
%      n = -5:0.1:5;
%      a = satlin(n);
%      plot(n,a)
%
%  Network Use
%
%    To change a network so that a layer uses SATLIN, set
%    NET.layers{i}.transferFcn to 'satlin'.
%
%    Call SIM to simulate the network with SATLIN.
%    See NEWHOP for simulation examples.
%
%  Algorithm
%
%      satlin(n) = 0, if n <= 0
%                  n, if 0 <= n <= 1
%                  1, if 1 <= n
%
%  See also SIM, POSLIN, SATLINS, PURELIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:35 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dsatlin';
    case 'name',
      a = 'Saturating Linear';
    case 'output',
      a = [0 1];
    case 'active',
      a = [0 1];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'none';
    nntobsu('satlin','Use SATLIN(''deriv'') instead of SATLIN(''delta'').')
    case 'init',
    nntobsu('satlin','Use network propreties to obtain initialization info.')
      a = 'rands';
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('satlin','Use SATLIN(NETSUM(Z,B)) instead of SATLIN(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

a = max(0,min(1,n));
