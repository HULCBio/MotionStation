function a = mytf(n)
%MYTF Example custom transfer function.
%
%  Use this function as a template to write your own function.
%  
%  Calculation Syntax
%
%    A = mytf(N)
%      N - SxQ matrix of Q net input (column) vectors.
%      A - SxQ matrix of Q output (column) vectors.
%
%  Information Syntax
%
%    info = mytf(code) returns useful information for each CODE string:
%      'version' - Returns the Neural Network Toolbox version (3.0).
%      'deriv'   - Returns the name of the associated derivative function.
%      'output'  - Returns the output range.
%      'active'  - Returns the active input range.
%
%  Example
%
%    n = -5:.1:5;
%    a = mytf(n);
%    plot(n,a)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

if nargin < 1, error('Not enough arguments.'); end

if isstr(n)
  switch (n)
    case 'version'
    a = 3.0;       % <-- Must be 3.0.
    
    case 'deriv'
    a = 'mydtf';   % <-- Replace with the name of your
                   %     associated function or ''
    case 'output'
    a = [-1 1];    % <-- Replace with the minimum and maximum
                   %     output values of your transfer function
    case 'active'
    a = [-2 2];    % <-- Replace with the range of inputs where
                   %     the outputs are most sensative to changes.
            
    otherwise, error('Unrecognized code.')
  end

else

  a = 1./(n.^8+1);   % <-- Replace with your calculation

end
