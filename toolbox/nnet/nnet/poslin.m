function a = poslin(n,b)
%POSLIN Positive linear transfer function.
%  
%  Syntax
%
%    A = poslin(N)
%    info = poslin(code)
%
%  Description
%  
%    POSLIN is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    POSLIN(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns the maximum of 0 and each element of N.
%  
%    POSLIN(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here the code to create a plot of the POSLIN transfer function.
%  
%      n = -5:0.1:5;
%      a = poslin(n);
%      plot(n,a)
%
%  Network Use
%
%    To change a network so a layer uses POSLIN set
%    NET.layers{i}.transferFcn to 'poslin'.
%
%    Call SIM to simulate the network with POSLIN.
%
%  Algorithm
%
%      poslin(n) = n, if n >= 0
%                = 0, if n <= 0
%
%  See also SIM, PURELIN, SATLIN, SATLINS.

% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dposlin';
    case 'name',
      a = 'Positive Linear';
    case 'output',
      a = [0 +inf];
    case 'active',
      a = [0 +inf];
    case 'type',
      a = 1;
  
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

a = max(0,n);
