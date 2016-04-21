function a = radbas(n,b)
%RADBAS Radial basis transfer function.
%  
%  Syntax
%
%    A = radbas(N)
%    info = radbas(code)
%
%  Description
%  
%    RADBAS is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    RADBAS(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns each element of N passed through a
%    radial basis function.
%  
%    RADBAS(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%  
%  Examples
%
%    Here we create a plot of the RADBAS transfer function.
%  
%      n = -5:0.1:5;
%      a = radbas(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses RADBAS
%    by calling NEWPNN or NEWGRNN.
%
%    To change a network so that a layer uses RADBAS set
%    NET.layers{i}.transferFcn to 'radbas'.
%
%    In either case, call SIM to simulate the network with RADBAS.
%    See NEWPNN or NEWGRNN for simulation examples.
%
%  Algorithm
%
%    RADBAS(N) calculates its output with according to:
%
%      a = exp(-n^2)
%
%  See also SIM, TRIBAS, DRADBAS.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:26 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv',
      a = 'dradbas';
    case 'name',
      a = 'Radial Basis';
    case 'output',
      a = [0 1];
    case 'active',
      a = [-2 +2];
    case 'type',
      a = 1;
  
  % **[ NNT2 Support ]**
    case 'delta',
      a = 'none';
    nntobsu('radbas','Use RADBAS(''deriv'') instead of RADBAS(''delta'').')
    case 'init',
      a = 'rands';
    nntobsu('radbas','Use network propreties to obtain initialization info.')
    
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2  
  nntobsu('radbas','Use RADBAS(NETPROD(Z,B)) instead of RADBAS(Z,B).')
  n = n .* b(:,ones(1,size(n,2)));
end

a = exp(-(n.*n));
