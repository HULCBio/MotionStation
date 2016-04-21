function a = compet(n,b)
%COMPET Competitive transfer function.
%  
%  Syntax
%
%    A = compet(N)
%    info = compet(code)
%
%  Description
%  
%    COMPET is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    COMPET(N) takes one input argument,
%      N - SxQ matrix of net input (column) vectors.
%    and returns output vectors with 1 where each net input
%    vector has its maximum value, and 0 elsewhere.
%  
%    COMPET(code) returns information about this function.
%    These codes are defined:
%      'deriv'  - Name of derivative function.
%      'name'   - Full name.
%      'output' - Output range.
%      'active' - Active input range.
%
%    COMPET does not have a derivative function.
%  
%  Examples
%
%    Here we define a net input vector N, calculate the output,
%    and plot both with bar graphs.
%
%      n = [0; 1; -0.5; 0.5];
%      a = compet(n);
%      subplot(2,1,1), bar(n), ylabel('n')
%      subplot(2,1,2), bar(a), ylabel('a')
%
%  Network Use
%
%    You can create a standard network that uses COMPET
%    by calling NEWC or NEWPNN.
%
%    To change a network so a layer uses COMPET set
%    NET.layers{i,j}.transferFcn to 'compet'.
%
%    In either case, call SIM to simulate the network with COMPET.
%    See NEWC or NEWPNN for simulation examples.
%
%  See also SIM, SOFTMAX.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:35:14 $

if nargin < 1,error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = '';
    case 'name',
      a = 'Competitive';
    case 'output',
      a = [0 1];
    case 'active',
      a = [-inf inf];
    case 'type',
      a = 2;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'none';
    nntobsu('compet','Use COMPET(''deriv'') instead of COMPET(''delta'').')
    case 'init',
      a = 'midpoint';
    nntobsu('compet','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
  
% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('compet','Use COMPET(NETSUM(Z,B)) instead of COMPET(Z,B).')
  n = n + b(:,ones(1,size(n,2)));
end

[S,Q] = size(n);
[maxn,indn] = max(n,[],1);
a = sparse(indn,1:Q,ones(1,Q),S,Q);
