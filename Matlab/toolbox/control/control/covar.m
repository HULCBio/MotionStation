function [p,q] = covar(a,b,c,d,w)
%COVAR  Covariance response of LTI models to white noise inputs.
%
%   P = COVAR(SYS,W) computes the output response covariance 
%   P = E[yy'] when the LTI model SYS is driven by Gaussian 
%   white noise inputs. The noise intensity W is defined by
%
%      E[w(t)w(tau)'] = W delta(t-tau)  (delta(t) = Dirac delta)
%
%   in continuous time, and by
%
%      E[w(k)w(n)'] = W delta(k,n)   (delta(k,n) = Kronecker delta)
%
%   in discrete time.  Note that unstable systems have infinite 
%   covariance response.
%
%   [P,Q] = COVAR(SYS,W) also returns the state covariance Q = E[xx']
%   when SYS is a state-space model.
%
%   If SYS is an array of LTI models with dimensions [NY NU S1 ... Sp], 
%   the array P has dimensions [NY NY S1 ... Sp] and
%      P(:,:,k1,...,kp) = COVAR(SYS(:,:,k1,...,kp)) .  
%
%   See also LTIMODELS, LYAP, DLYAP.

% Old help
%COVAR  Covariance response of continuous system to white noise.
%   [P,Q] = COVAR(A,B,C,D,W) computes the covariance response of the 
%   continuous state-space system (A,B,C,D) to Gaussian white noise
%   inputs with intensity W,
%
%       E[w(t)w(tau)'] = W delta(t-tau) 
%
%   where delta(t) is the dirac delta.  P and Q are the output and 
%   state covariance responses:
%
%       P = E[yy'];  Q = E[xx'];
%
%   P = COVAR(NUM,DEN,W) computes the output covariance response of 
%   the polynomial transfer function system.  W is the intensity of 
%   the input noise.
%
%   Warning: Unstable systems or systems with a non-zero D matrix have
%   infinite covariance response.
%
%   See also: DCOVAR,LYAP and DLYAP.

%   Clay M. Thompson  7-3-90
%       Revised by Wes Wang 8-5-92
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:13:31 $

error(nargchk(3,5,nargin));
if ~((nargin==3)|(nargin==5)), error('Wrong number of input arguments.'); end

% --- Determine which syntax is being used ---
if (nargin == 3) 
  % T.F. syntax
  [num,den] = tfchk(a,b);
  [p,q] = covar(tf(num,den),c);

else
  % State-space syntax
  [msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
  [p,q] = covar(ss(a,b,c,d),w);

end

% end covar


