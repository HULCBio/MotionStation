% function [sysout,sig] = sysbal(sys,tol)
%
%   Finds a truncated balanced realization of the system
%   state-space model. Eigenvalues of A must have negative
%   real part. The result is truncated to retain all Hankel-
%   singular values greater than TOL. If TOL is omitted
%   then it is set to max(sig(1)*1.0E-12,1.0E-16).
%
%   See also: HANKMR, REORDSYS, FRWTBAL, SFRWTBLD, SNCFBAL,
%             SRELBAL, SRESID, SVD, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [sysout,sig] = sysbal(sys,tol)
   if nargin == 0
     disp(['usage: [sysout,sig] = sysbal(sys,tol)']);
     return
   end %if nargin<1

   [A,B,C,D]=unpck(sys);
   [n,m]=size(B); [p,n]=size(C);
   [T,A]=schur(A);
   B = T'*B;
   C = C*T;
 % check that A is stable.
   if any(real(eig(A))>=0),
     disp('SYS must be stable')
     return
    end

 % find observability Gramian, S'*S (S upper triangular)
   S = sjh6(A,C);
 % find controllability Gramian R*R' (R upper triangular)
   perm = n:-1:1;
   R = sjh6(A(perm,perm)',B(perm,:)');
   R = R(perm,perm)';
 % calculate the Hankel-singular values
   [U,T,V] = svd(S*R);
   sig = diag(T);
 % balancing coordinates
   T = U'*S;
   B = T*B; A = T*A;
   T = R*V;
   C = C*T; A = A*T;
    % calculate the truncated dimension nn
   if nargin<2 tol=max([sig(1)*1.0E-12,1.0E-16]);end;
   nn = n;
   for i=n:-1:1, if sig(i)<=tol nn=i-1; end; end;
   if nn==0, sysout=D;
     else
     sig = sig(1:nn);
     % diagonal scaling  by sig(i)^(-0.5)
     irtsig = sig.^(-0.5);
     onn=1:nn;
     A(onn,onn)=A(onn,onn).*(irtsig*irtsig');
     B(onn,:)=(irtsig*ones(1,m)).*B(onn,:);
     C(:,onn)=C(:,onn).*(ones(p,1)*irtsig');
     sysout=pck(A(onn,onn),B(onn,:),C(:,onn),D);
    end


%
%