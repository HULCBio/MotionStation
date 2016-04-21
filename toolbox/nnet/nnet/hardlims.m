function a = hardlims(n,b)
%HARDLIMS Symmetric hard limit transfer function.
%  
%  Syntax
%
%    A = hardlims(N)
%    info = hardlims(code)
%
%  Description
%  
%    HARDLIMS is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    HARDLIMS(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns 1 where N is positive, -1 elsewhere.
%  
%    HARDLIMS(CODE) returns useful information for each CODE string:
%      'deriv'  - Name of derivative function.
%      'name'   - Full name.
%      'output' - Output range.
%      'active' - Active input range.
%  
%  Examples
%
%    Here is how to create a plot of the HARDLIMS transfer function.
%  
%      n = -5:0.1:5;
%      a = hardlims(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses HARDLIMS
%    by calling NEWP.
%
%    To change a network so that a layer uses HARDLIMS set
%    NET.layers{i}.transferFcn to 'hardlims'.
%
%    In either case, call SIM to simulate the network with HARDLIMS.
%    See NEWP for simulation examples.
%
%  Algorithm
%
%      hardlims(n) = 1, if n >= 0
%                   -1, otherwise
%
%  See also SIM, HARDLIMS.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:05 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dhardlms';
    case 'name',
      a = 'Symmetric Hard Limit';
    case 'output',
      a = [-1 1];
    case 'active',
      a = [0 0];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'none';
    nntobsu('hardlim','Use HARDLIMS(''deriv'') instead of HARDLIMS(''delta'').')
    case 'init',
      a = 'rands';
    nntobsu('hardlims','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
  
% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('hardlimsS','Use HARDLIM(NETSUM(Z,B)) instead of HARDLIMS(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

a = 2*(n >= 0)-1;
