function d=mydwf(code,w,p,z)
%MYDWF Example custom weight derivative function for MYWF.
%
%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    dZ_dP = mydwf('p',W,P,Z)
%    dZ_dW = mydwf('w',W,P,Z)
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%      Z - SxQ matrix of Q weighted input (column) vectors.
%      dZ_dP - SxR derivative dZ/dP.
%      dZ_dW - RxQ derivative dZ/dW.
%
%  Example
%
%    w = rand(1,5);
%    p = rand(5,1);
%    z = mywf(w,p)
%    dz_dp = mydwf('p',w,p,z)
%    dz_dw = mydwf('w',w,p,z)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

% **  Replace the following calculations with your
% **  derivative calculation.  The only constraint is that
% **  the weight function must be a sum of elements, where
% **  each element i is a function of w(i) and p(i) only.

switch code
  case 'p', d = 2*w.*p';
  case 'w', d = p.^2;
  otherwise, error(['Unrecognized code.'])
end

% **  Note that you have both the transfer functions input N and
% **  output A available, which can often allow a more efficient
% **  calculation of the derivative than with just N.
