% [a,b2]=ucreg(a,b2,c1,d12,knobjw)
%
% Called by DGOPTRIC
%
% Removes unit circle zeros in
%
%                    [ A - z I    B2 ]
%           P12(z) = [               ]
%                    [   C1      D12 ]
%
% via the eps-regularization [A,B2] -> (1+eps)*[A,B2]
%
% To regularize P21(z), call
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJW must be valued in [0,1] and controls the amount of
% eps-regularization (eps increases with KNOBJW)
%
% See also  DHINFRIC.

% Authors: P. Gahinet and A.J. Laub  2/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [a,b2,flag]=ucreg(a,b2,c1,d12,knobjw)

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
H = q(:,na2+m:-1:1)'*[mdiag(a,eye(na));c1 zeros(p1,na); zeros(m2,na2)];
E = q(:,na2+m:-1:1)'*[mdiag(eye(na),a');zeros(p1,na2);zeros(m2,na) -b2'];
zer=abs(eig(H(1:na2,:),E(1:na2,:)));



% regularize:

%if ~isempty(find(abs(zer-1) < max(tolreg,fact*macheps^(2/3)*max(zer)))),

if ~isempty(find(abs(zer-1) < tolreg)),

  a=(1+tolreg)*a; b2=(1+tolreg)*b2;
  flag=1;

end

