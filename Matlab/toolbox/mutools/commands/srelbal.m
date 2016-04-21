% function [sysout,sig,sysfact] = srelbal(sys,tol)
%
%   Find a truncated stochastically balanced realization of
%   the system state-space model SYS.  All the eigenvalues
%   of SYS must have negative real part. The result is
%   truncated to retain all Hankel singular values greater
%   than TOL.  The output parameter SYSFACT is a stable
%   minimum phase system such that SYS~*SYS = SYSFACT*SYSFACT~.
%   If TOL is omitted then it is set to max(SIG(1)*1.0E-12,1.0E-16).
%   SIG imply the achievable relative errors with STRUNC(SYSOUT,K).
%
%   See also: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL,
%             SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [sysout,sig,sysfact] = srelbal(sys,tol)

   if nargin<1
     disp('usage: [sysout,sig,sysfact] = srelbal(sys,tol)');
     return;
   end
   [A,B,C,D]=unpck(sys);
   [systype,p,m,n]=minfo(sys);
   if systype~='syst', error('sys must be SYSTEM');end
   [T,A]=schur(A);
   B = T'*B;
   C = C*T;

 % find observability Gramian, S'*S (S upper triangular)

   S = sjh6(A,C);
   H = B'*S'*S+D'*C;
   Ham = [A' zeros(n); zeros(n) -A] - [H';B]*inv(D'*D)*[B' -H];
   [U,Hamm]=schur(Ham);
   if any(imag(sys)), [U,Hamm]=ocsf(U,Hamm,'s');
     else [U,Hamm]=orsf(U,Hamm,'s'); end
   [R,RR]=schur((U(1:n,1:n)'*U(n+1:2*n,1:n)+U(n+1:2*n,1:n)'*U(1:n,1:n))/2);
    R=(U(n+1:2*n,1:n)*R)./(ones(n,1)*sqrt(abs(diag(RR)')));
   [qdw,Dw]=qr(D);Dw=Dw(1:m,1:m)';
   L=(B-R*R'*H')/(Dw');
   % calculate the Hankel-singular values
   [U,T,V] = svd(S*R);
   sig = diag(T);

 % balancing coordinates

   T = U'*S;
   B = T*B; A = T*A; L=T*L;
   T = R*V;
   C = C*T; A = A*T; H=H*T;
    % calculate the truncated dimension nn
   if nargin<2 tol=max([sig(1)*1.0E-12,1.0E-16]);end;
   nn = n;
   for i=n:-1:1, if sig(i)<=tol nn=i-1; end; end;
   if nn==0, sysout=D; sysfact=Dw;
     else
     sig = sig(1:nn);
     % diagonal scaling  by sig(i)^(-0.5)
     irtsig = sig.^(-0.5);
     onn=1:nn;
     A(onn,onn)=A(onn,onn).*(irtsig*irtsig');
     B(onn,:)=(irtsig*ones(1,m)).*B(onn,:);
     C(:,onn)=C(:,onn).*(ones(p,1)*irtsig');
     L(onn,:)=(irtsig*ones(1,m)).*L(onn,:);
     H(:,onn)=H(:,onn).*(ones(m,1)*irtsig');
     sysout=pck(A(onn,onn),B(onn,:),C(:,onn),D);
     sysfact=pck(A(onn,onn),L(onn,:),H(:,onn),Dw);
    end
%
%