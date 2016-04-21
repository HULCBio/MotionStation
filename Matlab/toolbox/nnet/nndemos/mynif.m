function n=mynif(varargin)
%MYNIF Example custom net input function.
%
%  Use this function as a template to write your own function.
%  
%  Calculation Syntax
%
%    N = mynif(Z1,Z2,...)
%      Zi - SxQ matrix of Q weighted (column) vectors.
%      N - SxQ matrix of Q net input (column) vectors.
%
%  Information Syntax
%
%    info = mynif(code) returns useful information for each CODE string:
%      'version' - Returns the Neural Network Toolbox version (3.0).
%      'deriv'   - Returns the name of the associated derivative function.
%
%  Example
%
%    z1 = rand(4,5);
%    z2 = rand(4,5);
%    z3 = rand(4,5);
%    n = mynif(z1,z2,z3)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

if nargin < 1, error('Not enough arguments.'); end

n = varargin{1};

if isstr(n)
  switch n
    case 'version'
    a = 3.0;       % <-- Must be 3.0.
    
    case 'deriv'
    a = 'mydnif';  % <-- Replace with the name of your
                   %     associated derivative function or ''
    otherwise
      error('Unrecognized code.')
  end
  
else

% **  Replace the following calculation with your own.  The only
% **  constraint is that the function must not be sensative
% **  to the order of its input arguments.
% **  In other words, MYNIF(Z1,Z2,Z3) must return the same
% **  values as MYNIF(Z2,Z3,Z1), MYNIF(Z1,Z3,Z2), etc.
  
  n = 1./n;
  for i=2:length(varargin)
    n = n + 1./varargin{i};
  end
  n = 1./n;
  
end
