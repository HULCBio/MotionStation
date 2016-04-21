% a=jwreg(a,b2,c1,d12,knobjw)
%
% Called by GOPTRIC / PLANTREG.
%
% Removes jw-axis zeros in
%
%                    [ A - s I    B2 ]
%           P12(s) = [               ]
%                    [ C1        D12 ]
%
% via the eps-regularization A -> A + eps*I.
%
% To regularize P21(s), call
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJW must be valued in [0,1] and controls the amount of
% eps-regularization (eps increases with KNOBJW)
%
% See also HINFRIC.

% Authors: P. Gahinet and A.J. Laub  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [a,flag]=jwreg(a,b2,c1,d12,knobjw)

flag=0;  % 1 if regularized

if isempty(a),
  return
elseif nargin < 5,
  knobjw=0;
end

% tolerance
macheps=mach_eps;
toleig=sqrt(macheps);        % for detection of jw-axis zeros
tolreg=1e-5*10^(3*knobjw);   % amount of eps-regularization
fact=1+100*knobjw;           % adjustment of tol. for jw-axis zero detection

na=size(a,1);  p1=size(c1,1);  m2=size(d12,2);
dir12=[];



% detect jw-axis zeros of P12(s) via Hamiltonian spectrum at infinity

na2=2*na; m=p1+m2;
[q,r] = qr([zeros(na,p1) b2;-c1' zeros(na,m2);-eye(p1) d12;d12' zeros(m2)]);
H = q(:,na2+m:-1:1)'*[mdiag(a,-a');c1 zeros(p1,na); zeros(m2,na) b2'];
E = q(:,na2+m:-1:1)'*[eye(na2);zeros(m,na2)];
zer=eig(H(1:na2,:),E(1:na2,:))';
absrzer=abs(real(zer));


% regularize

%if ~isempty(find(absrzer < fact*toleig*abs(imag(zer)) | ...
%             absrzer < fact*max(toleig,macheps^(2/3)*max(abs(zer))))),

if ~isempty(find(absrzer < fact*toleig*abs(imag(zer)) | ...
             absrzer < max(tolreg,fact*macheps^(2/3)*max(abs(zer))))),

  a=a+tolreg*eye(na);
  flag=1;

end

