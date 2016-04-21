function [p,q] = covar(sys,w)
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
%      E[w(k)w(n)'] = W delta(k,n)  (delta(k,n) = Kronecker delta)
%
%   in discrete time.  Note that unstable systems or continuous-time 
%   models with non-zero feedthrough have infinite covariance response.
%
%   [P,Q] = COVAR(SYS,W) also returns the state covariance Q = E[xx']
%   when SYS is a state-space model.
%
%   If SYS is an array of LTI models with dimensions [NY NU S1 ... Sp], 
%   the array P has dimensions [NY NY S1 ... Sp] and
%      P(:,:,k1,...,kp) = COVAR(SYS(:,:,k1,...,kp)) .  
%
%   See also LTIMODELS, LYAP, DLYAP.

%   Clay M. Thompson  7-3-90
%       Revised by Wes Wang 8-5-92
%       P. Gahinet  7-22-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:18:21 $

error('COVAR is not supported for FRD models.')
