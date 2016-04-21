function [a, b] = d2d(phi, gam, t1, t2)
%D2D Convert discrete state-space models to models with diff. sampling times.
%   [A2, B2] = D2D(A1, B1, T1, T2) converts the discrete-time system:
%
%     x[n+1] = A1 * x[n] + B1 * u[n]
%
%   with a sampling rate of T1 to a discrete system with a sampling rate of T2.
%   The method is accurate for constant inputs. For non-integer multiples of T1
%   and T2, D2D may return complex A and B matrices. 
%
%   See also D2CI and C2D.

%   Copyright 1990-2002 The MathWorks, Inc.
%   Andrew C. W. Grace 2-20-91, Bora Eryilmaz 3-12-02
%   $Revision: 1.18 $   $Date: 2002/04/10 18:28:18 $

error(nargchk(4,4,nargin));
error(abcdchk(phi,gam));

[m,n]  = size(phi);
[m,nb] = size(gam);

% Pre-initialize B to handle the edge case of d2d([],[],t1,t2)
b = zeros(m,nb);
nonzero = [1:nb];

% Sample time ratio
rTs = t2/t1;
if abs(round(rTs)-rTs) < sqrt(eps)*rTs
  rTs = round(rTs);
end

RealFlag = isreal(phi) & isreal(gam);
% Look for real negative poles
p = eig(phi);
if any(imag(p)==0 & real(p)<=0) & rem(rTs,1)
  %%% This should be deleted and replaced with the commented code below ...
  s = [phi gam(:,nonzero); zeros(nb,n) eye(nb)]^rTs;
  if RealFlag
    s = real(s);
  end
  a = s(1:n,1:n);
  if length(nonzero)
    b(:,nonzero) = s(1:n,n+1:n+nb);
  end
  %%% ... when increasing number of states can be accomodated in dlinmod,
  %%% and d2ci can return augmented state matrices.
  % Negative real poles with fractional resampling: let D2C handle it
  %   try
  %     [a,b] = d2ci(phi,gam,t1);
  %     [a,b] = c2d(a,b,t2);
  %   catch
  %     rethrow(lasterror)
  %   end
else
  % Proceed directly
  if rTs == round(rTs),
    s = [phi gam(:,nonzero); zeros(nb,n) eye(nb)]^rTs;
  else
    % Replace this with s = expm(rTs*logm(M)) when logm([]) returns [].
    M = [phi gam(:,nonzero); zeros(nb,n) eye(nb)];
    if ~isempty(M)
      s = expm(rTs*logm(M));
    else
      s = [];
    end
  end
  if RealFlag
    s = real(s);
  end
  a = s(1:n,1:n);
  if length(nonzero)
    b(:,nonzero) = s(1:n,n+1:n+nb);
  end
end
