function a = tansig(n,b)
%TANSIG Hyperbolic tangent sigmoid transfer function.
%  
%  Syntax
%
%    A = tansig(N)
%    info = tansig(code)
%
%  Description
%  
%    TANSIG is a transfer function.  Transfer functions
%    calculate a layer's output from its net input.
%  
%    TANSIG(N) takes one input,
%      N - SxQ matrix of net input (column) vectors.
%    and returns each element of N squashed between -1 and 1.
%  
%    TANSIG(CODE) returns useful information for each CODE string:
%      'deriv'  - Returns name of derivative function.
%      'name'   - Returns full name.
%      'output' - Returns output range.
%      'active' - Returns active input range.
%
%    TANSIG is named after the hyperbolic tangent which has the
%    same shape.  However, TANH may be more accurate and is
%    recommended for applications that require the hyperbolic tangent.
%  
%  Examples
%
%    Here the code to create a plot of the TANSIG transfer function.
%  
%      n = -5:0.1:5;
%      a = tansig(n);
%      plot(n,a)
%
%  Network Use
%
%    You can create a standard network that uses TANSIG
%    by calling NEWFF or NEWCF.
%
%    To change a network so a layer uses TANSIG set
%    NET.layers{i,j}.transferFcn to 'tansig'.
%
%    In either case, call SIM to simulate the network with TANSIG.
%    See NEWFF or NEWCF for simulation examples.
%
%  Algorithm
%
%    TANSIG(N) calculates its output according to:
%
%      n = 2/(1+exp(-2*n))-1
%
%    This is mathematically equivalent to TANH(N).  It differs
%    in that it runs faster than the MATLAB implementation of TANH,
%    but the results can have very small numerical differences.  This
%    function is a good trade off for neural networks, where speed is
%    important and the exact shape of the transfer function is not.
%
%  See also SIM, DTANSIG, LOGSIG.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:55 $

if nargin < 1, error('Not enough arguments.'); end

% FUNCTION INFO
if isstr(n)
  switch (n)
    case 'deriv'
    a = 'dtansig';
    case 'name'
    a = 'Tan Sigmoid';
    case 'output'
    a = [-1 1];
    case 'active'
    a = [-2 2];
    case 'type'
    a = 1;
  
    % **[ NNT2 Support ]**
    case 'delta'
    a = 'deltatan';
    nntobsu('tansig','Use TANSIG(''deriv'') instead of TANSIG(''delta'').')
    case 'init'
    a = 'nwtan';
    nntobsu('tansig','Use network propreties to obtain initialization info.')
   
    otherwise, error('Unrecognized code.')
  end
  return
end

% CALCULATION

% **[ NNT2 Support ]**
if nargin == 2
  nntobsu('tansig','Use TANSIG(NETSUM(Z,B)) instead of TANSIG(Z,B).')
  n=n+b(:,ones(1,size(n,2)));
end

a = 2 ./ (1 + exp(-2*n)) - 1;
i = find(~finite(a));
a(i) = sign(n(i));
