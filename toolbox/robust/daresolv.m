function [p1,p2,lamp,perr,wellposed,P] = daresolv(A,B,Q,R,aretype)
%DARESOLV Discrete algebraic Riccati equation solver (eigen & schur).
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = DARESOLV(A,B,Q,R,ARETYPE) computes the
% solution to the discrete algebraic Riccati equation
%                                   -1
%            A'PA - P - A'PB(R+B'PB)  B'PA + Q = 0
%
%   based on the "aretype" one selects:
%
%      aretype = 'eigen' ---- Eigenstructure approach [default]
%      aretype = 'schur' ---- Schur vector approach
%      aretype = 'dare'  ---- Control Systems Toolbox DARE 
%
%  Outputs:   P = P2/P1 riccati solution
%             [P1;P2] stable eigenspace of hamiltonian matrix
%             LAMP closed loop eigenvalues
%             PERR residual error matrix
%             WELLPOSED = 'TRUE ' if hamiltonian has no imaginary-axis
%                  eigenvalues, otherwise 'FALSE'

% R. Y. Chiang & M. G. Safonov 2/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.12.4.3 $
% All Rights Reserved.

wellposed='TRUE ';  %initialize

if nargin == 4
   aretype = 'eigen';
end

aretype = lower(aretype);

%
[n,n] = size(A);
%
% ------ If A is stable and Q is zero, p2 = zero(n), p1 = eye(n)
%
lamA = eig(A);
ind = find(abs(lamA)>1);
if (sum(ind) == 0) & (norm(Q,'fro') == 0)
    lamp = [];
    p2 = zeros(n); p1 = eye(n);
    p = p2; perr = p2; P = p2;
   return
end
%
S = B/R*B';
%
% ------ Control System Toolbox DARE approach:
% 
if issame(aretype,'dare') | min(abs(lamA))<1e-12
   [p1,p2,t,report]=dare(A,B,Q,R,'implicit');
   [lam_h,ind] = sort(abs(t));
   lamp = t(ind(1:n));
   if report, wellposed='FALSE'; end
   P = real(p2/p1);
   perr = A'*P/(eye(n)+S*P)*A + Q - P;
   return
end

ham = [A+S/A'*Q -S/A';-A'\Q inv(A')];
%
% ------ Eigenstructure approach:
%
if aretype == 'eigen'
   [v,t] = reig(ham,2);
   if rcond(v) < 1.e-12,
      aretype = 'schur';
   end
   p1 = v(1:n,1:n);
   p2 = v((n+1):(2*n),1:n);
end
%
% ------ Schur vector approach:
%
if aretype == 'schur'
   % compute scaling factor alpha
   [tbal,junk]=balance([0, norm(S,1);norm(Q,1), 0]);
   tbal=diag(max(tbal'));
   alpha=tbal(2,2)/tbal(1,1);

   % compute stable eigenspace vv of scaled Hamiltonian
   ham = real([A+S/A'*Q -alpha*S/A';-A'\Q/alpha inv(A')]);
   [v,t,m,swap] = cschur(ham,6);
   vv = [real(v(:,1:m)) imag(v(:,1:m))];
   %if m~=n, warning('ill conditioned hamiltonian eigenproblem'),end
   
   % unscale eigenspace vv
   vv(1:n,:)=vv(1:n,:)/alpha;
   
   [vh,rh] = qr(vv);
   p1 = vh(1:n,1:n);
   p2 = vh(n+1:2*n,1:n);
end
%
P = real(p2/p1);
%
perr = A'*P/(eye(n)+S*P)*A + Q - P;
%
% ------ Assigning closed-loop roots and
%        checking hamiltonian jw-axis roots:
%
t=eig(t);
[lam_h,ind] = sort(abs(t));
lamp = t(ind(1:n));
if (~((lam_h(n)<1) & (lam_h(n+1)>1)))
     wellposed='FALSE';
end
%
% ------- End of DARESOLV.M ---- % RYC/MGS %
