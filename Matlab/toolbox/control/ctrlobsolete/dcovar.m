function [p,q] = dcovar(a,b,c,d,w)
%DCOVAR Covariance response of discrete system to white noise.
%
%   [P,Q] = DCOVAR(A,B,C,D,W) computes the covariance response of the 
%   discrete state-space system (A,B,C,D) to Gaussian white noise
%   inputs with intensity W,
%
%       E[w(k)w(n)'] = W delta(k,n)
%
%   where delta(k,n) is the kronecker delta.  P and Q are the output
%   and state covariance response:
%
%       P = E[yy'];  Q = E[xx'];
%
%   P = DCOVAR(NUM,DEN,W) computes the output covariance response of
%   the polynomial transfer function system.  W is the intensity of 
%   the input noise.
%
%   See also  COVAR, LYAP and DLYAP.

%   Clay M. Thompson  7-5-90
%       Revised by Wes Wang 8-5-92
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:34:43 $

error(nargchk(3,5,nargin));
if ~((nargin==3)|(nargin==5)), error('Wrong number of input arguments.'); end

% --- Determine which syntax is being used ---
if (nargin == 3) 
  % T.F. syntax
  [num,den] = tfchk(a,b);
  [p,q] = covar(tf(num,den,-1),c);

else
  % State-space syntax
  [msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
  [p,q] = covar(ss(a,b,c,d,-1),w);

end

% end dcovar
