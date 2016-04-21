% nh2 = norm2(sys)
%
% Computes the H2 norm of a stable and strictly proper LTI
% system
%                               -1
%                 SYS = C (sE-A)  B
%
% This norm is given by
%                  ______________
%                 /
%                V  Trace(C*P*C')
%
% where P solves the Lyapunov equation:  A*P+P*A'+B*B' = 0.
%
% See also  LTISYS.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function nh2 = norm2(sys)

if nargin~=1,
  error('usage:  nh2=norm2(sys)');
elseif ~islsys(sys),
  error('SYS must be a SYSTEM matrix');
end

[a,b,c,d]=ltiss(sys);
if max(abs(d(:))) > 1e4*mach_eps,
  disp('SYS is not stricly proper: the H2 norm is infinite');
  nh2=Inf; return
elseif max(real(eig(a))) >= 0,
  error('SYS is not a stable system');
end

p=lyap(a,b*b');
nh2=sqrt(sum(diag(c*p*c')));
