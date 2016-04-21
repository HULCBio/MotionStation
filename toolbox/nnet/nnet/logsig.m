function a = logsig(n,b)
%LOGSIG Logarithmic sigmoid transfer function.
%  
%  Syntax
%
%    A = logsig(N)
%    info = logsig(code)
%
%  Description
%  
%    LOGSIG is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    LOGSIG(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns each element of N squashed between 0 and 1.
%  
%    LOGSIG(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here is code for creating a plot of the LOGSIG transfer function.
%  
%      n = -5:0.1:5;
%      a = logsig(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses LOGSIG
%    by calling NEWFF or NEWCF.
%
%    To change a network so a layer uses LOGSIG set
%    NET.layers{i}.transferFcn to 'logsig'.
%
%    In either case, call SIM to simulate the network with PURELIN.
%    See NEWFF or NEWCF for simulation examples.
%
%  Algorithm
%
%      logsig(n) = 1 / (1 + exp(-n))
%
%  See also SIM, DLOGSIG, TANSIG.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:36:20 $

if nargin < 1, error('Note enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv'
    a = 'dlogsig';
    case 'name'
    a = 'Log Sigmoid';
    case 'output'
    a = [0 1];
    case 'active'
    a = [-4 +4];
    case 'type'
    a = 1;
  
    % **[ NNT2 Support ]**
    case 'delta'
    a = 'deltalog';
    nntobsu('logsig','Use LOGSIG(''deriv'') instead of LOGSIG(''delta'').')
    case 'init'
    a = 'nwlog';
    nntobsu('logsig','Use network propreties to obtain initialization info.')
    
    otherwise, error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2
  n=n+b(:,ones(1,size(n,2)));
  nntobsu('logsig','Use LOGSIG(NETSUM(Z,B)) instead of LOGSIG(Z,B).')
end

a = 1 ./ (1 + exp(-n));
i = find(~finite(a));
a(i) = sign(n(i));
