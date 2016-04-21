function [a, b] = d2ci(phi, gam, t)
%D2CI Conversion of state space models from discrete to continuous time.
%   [A, B] = D2CI(Phi, Gamma, T)  converts the discrete-time system:
%
%     x[n+1] = Phi * x[n] + Gamma * u[n]
%
%   to the continuous-time state-space system:
%     .
%     x = Ax + Bu
%
%   assuming a zero-order hold on the inputs and sample time T.
%
%   See also D2CM and C2D.

%   J.N. Little 4-21-85
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $
%   Revised 9-22-88 JNL  Phi=1 case fixed,
%   10-17-90 A.Grace Better logm, and handles rows of zeros in gamma.

error(nargchk(3,3,nargin));
error(abcdchk(phi,gam));

[m,n] = size(phi);
[m,nb] = size(gam);

% phi = 1 case cannot be computed through matrix logarithm.  Handle
% as a special case.
if m == 1
  if phi == 1
    a = 0; b = gam/t;
    return
  end
end

% Remove rows in gamma that correspond to all zeros
b = zeros(m,nb);
nonzero = find(sum(abs(gam))~=0);
nz = length(nonzero);

% Do rest of cases using matrix logarithm.

[s,errest] = logm([[phi gam(:,nonzero)]; zeros(nz,n) eye(nz)]);
s = s/t;
a = s(1:n,1:n);
b(:,nonzero) = s(1:n,n+1:n+nz);
