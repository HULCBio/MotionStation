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

%   Clay M. Thompson  7-3-90
%       Revised by Wes Wang 8-5-92
%       P. Gahinet  7-22-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/10 23:13:15 $
error(nargchk(2,2,nargin))

% Get dimensions
StateCovar = isa(sys,'ss') & nargout>1;
sizes = size(sys);
Nu = sizes(2);

% Error checking
if ndims(w)>2,
   error('Noise covariance W must be a 2D matrix.')
elseif isequal(size(w),[1 1]),
   % Scalar expansion
   w = w * eye(Nu);
elseif any(size(w)-Nu),
   error('W must be a square matrix with as many rows as inputs in SYS.')
end

% Compute Cholesky factorization of W to check nonnegativity
[R,fail] = chol(w + eps * norm(w,1) * eye(Nu));
if fail,
   error('Noise covariance W must be positive semi-definite.')
end

% Compute output and state covariances
if StateCovar,
   % State-space model
   Nx = size(sys,'order');
   if length(Nx)>1,
      warning(...
         'State covariance only available for SS arrays with uniform number of states.')
      StateCovar = 0;
      Nx = 0;
   end
else
   Nx = 0;
end
p = zeros([sizes([1 1]) sizes(3:end)]);
q = zeros([Nx Nx sizes(3:end)]);
warn1 = '';
warn2 = '';

% Compute covariance matrices
Td = totaldelay(sys);
dTd = any(diff(Td,1,1),1);
nTd = max(Td(:));

if sys.Ts==0,
   % Continuous-time models
   for k=1:prod(sizes(3:end)),
      % Convert to state spze
      [ak,bk,ck,dk] = ssdata(sys(:,:,k));
      DTd = diag(Td(1,:,min(k,end)));
      
      if any(dTd(:,:,min(k,end))>1e3*eps*nTd) | ...
             norm(DTd*w-w*DTd,1)>1e3*eps*norm(w,1),
         error('Cannot compute covariance for specified delay system.');
      elseif any(real(eig(ak))>=0),
         warn1 = 'Unstable models have infinite output covariance.';
         qk = Inf;   pk = Inf;
      else
         qk = lyap(ak,bk*w*bk');
         pk = ck*qk*ck' + dk*w*dk';
      end
            
      % Store result
      p(:,:,k) = pk;
      if StateCovar,
         q(:,:,k) = qk;
      end            
   end
   
else
   % Discrete-time models
   for k=1:prod(sizes(3:end)),
      % Convert to state space
      DTd = diag(Td(1,:,min(k,end)));
      
      if any(dTd(:,:,min(k,end))>1e3*eps*nTd) | ...
            norm(DTd*w-w*DTd,1)>1e3*eps*norm(w,1),
         % Map delays to poles at z=0
         [ak,bk,ck,dk] = ssdata(delay2z(sys(:,:,k)));
         if StateCovar,
            StateCovar = 0;
            q = zeros([0 0 sizes(3:end)]);
            warn2 = 'Delays mapped to poles at z=0: discarding state covariance.';
         end
      else
         [ak,bk,ck,dk] = ssdata(sys(:,:,k));
      end
      
      if any(abs(eig(ak))>=1),
         warn1 = 'Unstable models have infinite output covariance.';
         qk = Inf;   pk = Inf;
      else
         qk = dlyap(ak,bk*w*bk');
         pk = ck*qk*ck' + dk*w*dk';
      end
      
      % Store result
      p(:,:,k) = pk;
      if StateCovar,
         q(:,:,k) = qk;
      end            
   end
   
end

% Flush out warnings
warning(warn1)
warning(warn2)


