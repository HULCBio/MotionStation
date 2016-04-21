function z=mywf(w,p)
%MYWF Example custom weight function.
%
%  Use this function as a template to write your own function.
%  
%  Calculation Syntax
%
%    Z = mywf(W,P)
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%      Z - SxQ matrix of Q weighted input (column) vectors.
%
%  Information Syntax
%
%    info = mytf(code) returns useful information for each CODE string:
%      'version' - Returns the Neural Network Toolbox version (3.0).
%      'deriv'   - Returns the name of the associated derivative function.
%
%  Example
%
%    w = rand(1,5);
%    p = rand(5,1);
%    z = mywf(w,p)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

if nargin < 1, error('Not enough arguments.'); end

if isstr(w)
  switch (w)
    case 'version'
    a = 3.0;       % <-- Must be 3.0.
    
    case 'deriv'
    a = 'mydtf';   % <-- Replace with the name of your
                   %     associated function or ''
    otherwise
      error('Unrecognized code.')
  end

else
% **  Replace the following calculation with your
% **  weighting calculation.  The only constraint, if you
% **  want to define a derivative function, is that Z must
% **  be a sum of i terms, where each ith term is only a
% **  a function of w(i) and p(i).

  z = w*(p.^2);
end
