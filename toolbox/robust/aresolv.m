function [p1,p2,lamp,perr,wellposed,p] = aresolv(a,q,R,aretype)
%ARESOLV Continuous algebraic Riccati equation solver (eigen & schur).
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = ARESOLV(A,Q,R,ARETYPE) computes the
% solution to the algebraic Riccati equation
%
%                     A'P + PA - PRP + Q = 0
%
%   based on the "aretype" one selects:
%
%                aretype = 'eigen' ---- Eigenstructure approach
%
%                aretype = 'schur' ---- Schur vector approach
%
%  Outputs:   P = P2/P1 riccati solution
%             [P1;P2] stable eigenspace of hamiltonian [A,-R;-Q,-A']
%             LAMP closed loop eigenvalues
%             PERR residual error matrix
%             WELLPOSED = 'TRUE ' if hamiltonian has no imaginary-axis
%                  eigenvalues, otherwise 'FALSE'

% R. Y. Chiang & M. G. Safonov 2/88
% Revised C. Moler 12/16/97 
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

wellposed='TRUE ';  %initialize

nag1 = nargin;
nag2 = nargout;

if nag1 == 3
   aretype = 'eigen';
end

aretype = lower(aretype); % convert the aretype string to lower case

%
[n,n] = size(a);
%
% ------ If A is stable and Q is zero, p2 = zero(n), p1 = eye(n)
%
lamA = eig(a);
ind = find(lamA>0);
if (sum(ind) == 0) & (norm(q,'fro') == 0)
   p2 = zeros(n); p1 = eye(n);
   p = p2; perr = p2; lamp = zeros(n,1);
   return
end
%
ham = real([a -R;-q -a']);
%
% ------ Eigenstructure approach:
%
if aretype == 'eigen'
   [v,t] = reig(ham);
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
   [tbal,junk]=balance([0, norm(-R,1);norm(-q,1), 0]);
   tbal=diag(max(tbal'));
   alpha=tbal(2,2)/tbal(1,1);


   % compute stable eigenspace vv of scaled Hamiltonian
   ham = real([a -alpha*R;-q/alpha -a']);
   [v,t,m,swap] = cschur(ham,1);
   vv = [real(v(:,1:m)) imag(v(:,1:m))];
   %if m~=n, warning('ill conditioned hamiltonian eigenproblem'),end
   
   % unscale eigenspace vv
   vv(1:n,:)=vv(1:n,:)/alpha;
  
   [vh,rh] = qr(vv);
   p1 = vh(1:n,1:n);
   p2 = vh(n+1:2*n,1:n);
end
%
if nag2 == 6
   p = real(p2/p1);
end
%
% ------ Residual of the Riccati solution:
%
perr = [p2' -p1']*[a -R;-q -a']*[p1;p2];
%
% ------ Assigning closed-loop poles and
%        checking hamiltonian jw-axis roots
%
t=eig(t);
[lam_h,ind] = sort(real(t));
lamp = t(ind(1:n));
if (~((lam_h(n)<0) & (lam_h(n+1)>0)))
     wellposed='FALSE';
end
%
% ------- End of ARESOLV.M ---- % RYC/MGS %
