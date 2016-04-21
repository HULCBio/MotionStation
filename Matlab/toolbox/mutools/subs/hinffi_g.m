%	[xinf,f,fail,hamx,hxmin] = hinffi_g(p,ncon,epr,gam,imethd);
%
%	solve the hamiltonian for xinf for the FULL
%       INFORMATION feedback case.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [xinf,f,fail,hamx,hxmin] = hinffi_g(p,ncon,epr,gam,imethd);

[a,bp,cp,dp,b1,b2,c1,d11,d12,ndata] = hinffi_p(p,ncon);
 fail = 0;
 np = max(size(a));
 np1 = ndata(1);
 np2 = ndata(2);
 nm1 = ndata(3);
 nm2 = ndata(4);
%
%  form r and rbar
%
 d1dot = [d11,d12];
 r = zeros(nm1+nm2,nm1+nm2);
 r(1:nm1,1:nm1) = -gam*gam*eye(nm1);
 r = r+d1dot'*d1dot;
%
% form hamiltonian hamx for xinf
%
 dum = ([bp;-c1'*d1dot]/r)*[d1dot'*c1,bp'];
 hamx = [a,0*a;-c1'*c1,-a']-dum;

 if imethd == 1
%
% Solve the Riccati equation using eigenvalue decomposition
%  	- Balance Hamiltonian
%
   [x1,x2,fail,hxmin,epkgdif] = ric_eig(hamx,epr);
    if fail == 1,                         % ric(x) has jw axis eigs
    else
% really should check the condition number of x1 before doing this
%  but the MATLAB `cond' command has problems
     xinf = real(x2/x1);
     if any(any(~finite(xinf)))
       fail = 1;
       xinf = [];
     end
   end
 elseif imethd == -1
%
% Solve the Riccati equation using eigenvalue decomposition
%       - No Balancing of Hamiltonian Matrix
%
   [x1,x2,fail,hxmin,epkgdif] = ric_eig(hamx,epr,1);
    if fail == 1,                         % ric(x) has jw axis eigs
    else
     xinf = real(x2/x1);
     if any(any(~finite(xinf)))
       fail = 1;
       xinf = [];
     end
   end
 elseif imethd == 2
%
% solve the Riccati equation using real schur decomposition
%  	- Balance Hamiltonian Matrix
%
   [x1,x2,fail,hxmin,epkgdif] = ric_schr(hamx,epr);
    if fail == 1 | fail == 3               % ric(x) has jw axis eigs
     xinf = [];
     fail = 1;
    elseif fail == 2 % ric(x) unequal number of pos and neg eigenvalues
     xinf = [];
     fail = 1;
    else
     xinf = real(x2/x1);
     if any(any(~finite(xinf)))
       fail = 1;
       xinf = [];
     end
   end
 elseif imethd == -2
%
% Solve the Riccati equation using real schur decomposition
%       - No Balancing of Hamiltonian Matrix
%
   [x1,x2,fail,hxmin,epkgdif] = ric_schr(hamx,epr,1);
    if fail == 1 | fail == 3               % ric(x) has jw axis eigs
     xinf = [];
     fail = 1;
    elseif fail == 2 % ric(x) unequal number of pos and neg eigenvalues
     xinf = [];
     fail = 1;
    else
     xinf = real(x2/x1);
     if any(any(~finite(xinf)))
       fail = 1;
       xinf = [];
     end
   end
 else
   error('type of solution method is invalid')
   return
 end
%
%  form f  submatrices
%
 if fail == 1
   f = [];
 else
   f = -r\(d1dot'*c1+bp'*xinf);
 end

%%%%%%  Trying to develop better testing methods  %%%%%%%%

% dum = ([bp;-c1'*d1dot]/r)*[d1dot'*c1,bp'];
% hamx = [a,0*a;-c1'*c1,-a']-dum;
% ah = hamx(1:np,1:np);
% rh = hamx(1:np,np+1:2*np);
% qh = hamx(np+1:2*np,1:np);

% disp(' eig of Xinf')
% rifd(eig(xinf))
% rifd(eig(ah+rh*xinf))
%
% norm(ah'*xinf + xinf*ah + xinf*rh*xinf - qh)
% pause

% A_tilde = a - (b2*[zeros(nm2,nm1) eye(nm2,nm2)]/r)*(d1dot'*c1 + bp'*xinf);
% max(real(eig(A_tilde)))
%  disp(' eig of hamX')
%  rifd(sort(eig(hamx)))
% A_tilde = a + (b2*[d12'*d11 eye(nm2,nm2)]*f);
% disp(' ')
% disp(['Max eigenvalue of A_tilde: ' num2str(max(real(eig(A_tilde))))])

% [cond(x1) cond(x2) norm(xinf - xinf') norm(xinf)]
%
%