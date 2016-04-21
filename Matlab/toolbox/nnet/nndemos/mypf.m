function perf = mypf(e,x,pp)
%MYPF Example custom performance function.
%
%  Use this function as a template to write your own function.
%  
%  Calculation Syntax
%
%    perf = mypf(E,X,PP)
%      E  - Matrix or cell array of error vector(s).
%      X  - Vector of all weight and bias values.
%      PP - Performance parameter.
%
%    perf = mypf(E,net)
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
%    e = rand(4,5);
%    x = rand(12,1);
%    pp = mypf('pdefaults')
%    perf = mypf(e,x,pp)

% Copyright 1997-2001 The MathWorks, Inc.
% $Revision: 1.4.2.1 $

if nargin < 1, error('Not enough arguments.'); end

if isstr(e)
  switch (e)
  case 'version'
    perf = 3.0;         % <-- Must be 3.0.
    
  case 'deriv',
    perf = 'mydpf';     % <-- Replace with the name of your derivative function or ''
    
  case 'name',
    perf = 'Custom';    % <-- Replace with your function's name
    
  case 'pnames',
    perf = {};          % <-- Add names of your function parameters (if any)
    
  case 'pdefaults'
    perf.x = 1;         % <-- Replace with the your own performance
    perf.y = 0.5;       % <-- parameter structure or null matrix [].
    
  otherwise, error('Unrecognized code.')
  end
  
else
  
  if isa(e,'cell')
    e = cell2mat(e);
  end
  
  if nargin == 2
    pp = x.performParam; % <-- delete this line if you don't use PP
    x = getx(net);       % <-- delete this line if you don't use X
  end
  
  % ** Replace the following calculation with your own
  % ** measure of performance.
  
  numErrors = prod(size(e));
  numWeightsBiases = length(x);
  perf =  sum(sum(abs(e))) * pp.x/numErrors + ...
    sum(abs(x)) * pp.y/numWeightsBiases;
  
end
