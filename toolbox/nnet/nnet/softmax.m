function a = softmax(n)
%SOFTMAX Soft max transfer function.
%  
%  Syntax
%
%    A = softmax(N)
%    info = softmax(code)
%
%  Description
%  
%    SOFTMAX is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    SOFTMAX(N) takes one input argument,
%      N - SxQ matrix of net input (column) vectors.
%    and returns output vectors with elements between 0 and 1,
%    but with their size relations intact.
%  
%    SOFTMAX('code') returns information about this function.
%    These codes are defined:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%
%    SOFTMAX does not have a derivative function.
%  
%  Examples
%
%    Here we define a net input vector N, calculate the output,
%    and plot both with bar graphs.
%
%      n = [0; 1; -0.5; 0.5];
%      a = softmax(n);
%      subplot(2,1,1), bar(n), ylabel('n')
%      subplot(2,1,2), bar(a), ylabel('a')
%
%  Network Use
%
%    To change a network so that a layer uses SOFTMAX, set
%    NET.layers{i,j}.transferFcn to 'softmax'.
%
%    Call SIM to simulate the network with SOFTMAX.
%    See NEWC or NEWPNN for simulation examples.
%
%  See also SIM, COMPET.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv', a = '';
    case 'name', a = 'Soft Max';
    case 'output', a = [0 1];
    case 'active', a = [-inf inf];
    case 'type', a = 2;
    otherwise, error('Unrecognized code.')
  end
  return
end

expn = exp(n);
a = expn / sum(expn,1);


% CALCULATION
[s,q] = size(n);
expn = exp(n);
denom = 1 ./ sum(expn,1);
a = expn .* denom(ones(1,s),:);

