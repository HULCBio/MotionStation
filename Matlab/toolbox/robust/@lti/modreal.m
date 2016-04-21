function [a1,b1,c1,d1,a2,b2,c2,d2] = modreal(varargin);
%MODREAL State-space modal truncation/realization.
%
% [A1,B1,C1,D1,A2,B2,C2,D2] = MODREAL(A,B,C,D,CUT) or
% [SYS2,SYS3] = MODREAL(SYS1,CUT)  produces a slow-fast
% modal realization based on the number "cut" one specifies.
%
% If "CUT" is less than the size(A), D1 = D + C2*inv(-A2)*B2; D2 = 0;
%
% If "CUT" is not provided, a complete modal realization is returned.

% R. Y. Chiang & M. G. Safonov 1/93
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $

disp('  ');
disp('        - - Working on modal form decomposition - -');

[emsg,nag1,xsflag,Ts,a,b,c,d,cut]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

n = size(a)*[1;0];
if nag1 < 5
   cut = n;
end

[X,Lam] = reig(a,2);
[rd,cd] = size(d);
A = Lam;   B = inv(X)*b; C = c*X; D = d;
ModalRes = norm(inv(X)*a*X - Lam)

if cut ~= n
   a1 = A(1:cut,1:cut); b1 = B(1:cut,:); c1 = C(:,1:cut);
   a2 = A(cut+1:n,cut+1:n); b2 = B(cut+1:n,:); c2 = C(:,cut+1:n);
   d1 = d + c2*inv(-a2)*b2; d2 = zeros(rd,cd);
else
   a1 = A; b1 = B; c1 = C; d1 = D; a2 = [];b2 = [];c2 = [];d2 = [];
end

%
if xsflag
   a1 = mksys(a1,b1,c1,d1);
   b1 = mksys(a2,b2,c2,d2);
end
%
% ------ End of MODREAL.M % RYC/MGS %