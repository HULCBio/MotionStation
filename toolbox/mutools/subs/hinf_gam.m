%	[xinf,yinf,f,h,fail,hamx,hamy,hxmin,hymin] =
%          hinf_gam(p,nmeas,ncon,epr,gam,imethd);
%
%	solve the hamiltonian for xinf and yinf for the hinfsyn program.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.4.3 $

function [xinf,yinf,f,h,fail,hamx,hamy,hxmin,hymin] = ...
                       hinf_gam(p,nmeas,ncon,epr,gam,imethd);

[a,bp,cp,dp,b1,b2,c1,c2,d11,d12,d21,d22,ndata] = hinf_sp(p,nmeas,ncon);
 fail = 0;
 hxmin = []; hymin = []; %new v5
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
 ddot1 = [d11;d21];
 rbar = zeros(np1+np2,np1+np2);
 rbar(1:np1,1:np1) = -gam*gam*eye(np1);
 rbar = rbar+ddot1*ddot1';
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
	xinf = [];
    else
% really should check the condition number of x1 before doing this
%  but the MATLAB `cond' command has problems.  Remove warning instead GJW
     warn = warning('off'); xinf = real(x2/x1); warning(warn)
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
     xinf = [];
    else
     warn = warning('off'); xinf = real(x2/x1); warning(warn)
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
     warn = warning('off'); xinf = real(x2/x1); warning(warn)
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
     warn = warning('off'); xinf = real(x2/x1); warning(warn)
     if any(any(~finite(xinf)))
       fail = 1;
       xinf = [];
     end
   end
 elseif imethd == 3
%
% Solve the Riccati equation using both eigenvalue and real schur decomposition
%       - Balance Hamiltonian Matrix
%
%
%   [x1,x2,faile,hxmin,epkgdif] = ric_eig(hamx,epr);
%    if faile == 1,                         % ric(x) has jw axis eigs
%    else
%     xinfe = real(x2/x1);
%     if any(any(~finite(xinfe)))
%       faile = 1;
%       xinf = [];
%     end
%   end
%   [x1,x2,fails,hxmin,epkgdif] = ric_schr(hamx,epr,1);
%    if fails == 1 | fails == 3               % ric(x) has jw axis eigs
%     xinf = [];
%     fails = 1;
%    elseif fails == 2 % ric(x) unequal number of pos and neg eigenvalues
%     xinf = [];
%     fails = 1;
%    else
%     xinfs = real(x2/x1);
%     if any(any(~finite(xinfs)))
%       fails = 1;
%       xinf = [];
%     end
%   end
else
   error('type of solution method is invalid')
   return
 end
%
%  form hamiltonian hamy for yinf
%
 dum = ([cp';-b1*ddot1']/rbar)*[ddot1*b1',cp];
 hamy = [a',0*a;-b1*b1',-a]-dum;
 if imethd == 1
%
% solve the Riccati equation using eigenvalue decomposition
%  	- Balance Hamiltonian
%
   [y1,y2,fail1,hymin] = ric_eig(hamy,epr);
    if fail1 == 1,                         % ric(y) has jw axis eigs
	yinf = [];
    else
     yinf = real(y2/y1);
     if any(any(~finite(yinf)))
       fail = 1;
       yinf = [];
     end
    end
 elseif imethd == -1
%
% solve the Riccati equation using eigenvalue decomposition
%       - No Balancing of Hamiltonian Matrix
%
   [y1,y2,fail1,hymin] = ric_eig(hamy,epr,1);
    if fail1 == 1,                         % ric(y) has jw axis eigs
	yinf = [];
    else
     yinf = real(y2/y1);
     if any(any(~finite(yinf)))
       fail = 1;
       yinf = [];
     end
    end
 elseif imethd == 2
%
% solve the Riccati equation using real schur decomposition
%  	- Balance Hamiltonian
%
   [y1,y2,fail1,hymin] = ric_schr(hamy,epr);
    if fail1 == 1 | fail1 == 3
     yinf = [];
     fail1 = 1;
    elseif fail1 == 2
     yinf = [];
     fail1 = 1;
    else
     yinf = real(y2/y1);
     if any(any(~finite(yinf)))
       fail = 1;
       yinf = [];
     end
    end
 elseif imethd == -2
%
% solve the Riccati equation using real schur decomposition
%       - No Balancing of Hamiltonian Matrix
%
   [y1,y2,fail1,hymin] = ric_schr(hamy,epr,1);
    if fail1 == 1 | fail1 == 3
     yinf = [];
     fail1 = 1;
    elseif fail1 == 2
     yinf = [];
     fail1 = 1;
    else
     yinf = real(y2/y1);
     if any(any(~finite(yinf)))
       fail = 1;
       yinf = [];
     end
    end
 end
%
%  form f, h, and their submatrices
%
 fail = fail | fail1;
 if fail == 1
   f = [];
   h = [];
 else
   f = -r\(d1dot'*c1+bp'*xinf);
   h = -(b1*ddot1'+yinf*cp')/rbar;
 end
%
%