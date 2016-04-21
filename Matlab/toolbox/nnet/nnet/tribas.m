function a = tribas(n)
%TRIBAS Triangular basis transfer function.
%  
%  Syntax
%
%    A = tribas(N)
%    info = tribas(code)
%
%  Description
%  
%    TRIBAS is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    TRIBAS(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns each element of N passed through a
%    radial basis function.
%  
%    TRIBAS(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here we create a plot of the TRIBAS transfer function.
%  
%      n = -5:0.1:5;
%      a = tribas(n);
%      plot(n,a)
%
%  Network Use
%
%    To change a network so that a layer uses TRIBAS, set
%    NET.layers{i}.transferFcn to 'tribas'.
%
%    Call SIM to simulate the network with TRIBAS.
%
%  Algorithm
%
%    TRIBAS(N) calculates its output with according to:
%
%      tribas(n) = 1 - abs(n), if -1 <= n <= 1
%                 = 0, otherwise
%
%  See also SIM, RADBAS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv', a = 'dtribas';
    case 'name', a = 'Triangle Basis';
    case 'output', a = [0 1];
    case 'active', a = [-1 +1];
    case 'type', a = 1;
    otherwise error('Unrecognized code.')
  end
  return
end

% CALCULATION
a = max(0,1-abs(n));
