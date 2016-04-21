
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function dsdsys=sdequiv(a,b1,b2,c1,c2,T,invT,S,s,h,delay)

% For a sampled data system with continuous part pck(a,[b1 b2],[c1;c2],[0])
% sampling period h.
% This function calculates a discrete time system which will have
% induced L2 norm < 1 if and only if the sampled data system does.
% see Barmieh and Pearson IEEE-TAC.
% It needs to be called after the routine
%	[T,invT,S,s]=ham2schr(a,b1,c1,.02/h);
%
% Returns dsdsys=[] if no solution.
%
%
% function dsdsys=sdequiv(a,b1,b2,c1,c2,T,invT,S,s,h,delay)


if nargin~=11,
    error('usage:dsdsys=sdequiv(a,b1,b2,c1,c2,T,invT,S,s,h,delay)');
    return
  end

s1=s(1); s2=s(2); s3=s(3);
% form matrices Gam, Phi, Omega, and Psi.
%
tn=max(size(S));
n=tn/2;


 if s3==0,
     idx1=1:n; idx2=n+1:tn; idx0=1:tn;
     blk=[T zeros(tn,2*tn)]*expm(h*[S eye(tn) zeros(tn,tn);...
                   zeros(tn,2*tn) eye(tn); zeros(tn,3*tn)]);
     blk(:,idx0)=blk(:,idx0)*invT;
     blk(:,tn+1:2*tn)=blk(:,tn+1:2*tn)*invT;
     blk(:,2*tn+1:3*tn)=blk(:,2*tn+1:3*tn)*invT;
     blk=real(blk);
     inv_Gam11=inv(blk(idx1,idx1));


     Gam21Gam11inv=blk(idx2,idx1)*inv_Gam11;
     Phi22_Phi12=blk(idx2,3*n+1:4*n)-Gam21Gam11inv*blk(idx1,3*n+1:4*n);
     Gam11invGam12=inv_Gam11*blk(idx1,idx2);
     Gam11invPhi12=inv_Gam11*blk(idx1,3*n+1:4*n);
     Om12_Phi12=blk(idx1,5*n+1:6*n)-blk(idx1,2*n+1:3*n)*...
                     inv_Gam11*blk(idx1,3*n+1:4*n);
     ad=blk(idx2,idx2)-Gam21Gam11inv*blk(idx1,idx2);
 end; %if s3==0

%if s3>0,   do all calculations using  formulae involving exp(-h*S3)
%instead of exp(h*S3)
if s3>0,
    idx1=1:n; idx2=n+1:tn; s4=n-s3;
    H1=S(1:s1,1:s1); H2=S(s1+1:s1+s2,s1+1:s1+s2);
    H3=S(s1+s2+1:s1+s2+s3,s1+s2+1:s1+s2+s3);

    % augment T and Tinv and partition
    [q,r]=qr(T(idx1,s1+s2+1:tn));
     T12 = T(idx1,s1+s2+1:tn);
     T12a = [T12  q(:,s3+1:n)];
     T11 = T(idx1,1:s1+s2);
     T21 = T(idx2,1:s1+s2);
     T22 = T(idx2,s1+s2+1:tn);
     T22z = [T22 zeros(n,n-s3)];
    [q,r]=qr(invT(s1+s2+1:tn,idx1)');
    invT21 = invT(s1+s2+1:tn,idx1);
    invT21a=[invT21; q(:,s3+1:n)'];
    invT11= invT(1:s1+s2,idx1);
    invT12= invT(1:s1+s2,idx2);
    invT22= invT(s1+s2+1:tn,idx2);
    invT22z= [invT22; zeros(s4,n)];

    T11hat=T12a\T11;
    invT11hat=invT11/invT21a;

    gam1hat=expm(h*H1);
    phi1hat=H1\(gam1hat-eye(s1));
    om1hat=H1\(phi1hat -h*eye(s1));

    blk2= [eye(s2) zeros(s2,2*s2)]*...
     expm(h*[H2 eye(s2) zeros(s2,s2); zeros(s2,2*s2) eye(s2);zeros(s2,3*s2)]);

    Gam1hat=[gam1hat zeros(s1,s2); zeros(s2,s1) blk2(:,1:s2)];
    Phi1hat=[phi1hat zeros(s1,s2); zeros(s2,s1) blk2(:,s2+1:2*s2)];
    Omega1hat= [om1hat zeros(s1,s2); zeros(s2,s1) blk2(:,2*s2+1:3*s2)];

    Gam2hat=expm(-h*H3);
    Gam2hatei=[Gam2hat zeros(s3,n-s3);zeros(n-s3,s3) eye(n-s3)];
    Phi2hat=-H3\(Gam2hat-eye(s3));
    Omega2hat=-H3\(Phi2hat -h*eye(s3));
    Gam11invl=inv([eye(s3) zeros(s3,n-s3); zeros(n-s3,n)]+...
                     T11hat*Gam1hat*invT11hat*Gam2hatei);
    Gam11invr=inv([eye(s3) zeros(s3,n-s3); zeros(n-s3,n)]+...
                     Gam2hatei*T11hat*Gam1hat*invT11hat);
    Gam11invGam123=real((invT21a\Gam11invr)*...
                       (Gam2hatei*T11hat*Gam1hat*invT12+invT22z));
    Gam11invPhi123=real(invT21a\(Gam11invr*...
               (Gam2hatei*T11hat*Phi1hat*invT12+[Phi2hat*invT22;zeros(s4,n)])));

   Gam21Gam11inv3=real((T21*Gam1hat*invT11hat*Gam2hatei+T22z)*Gam11invl/T12a);


   ad3= real(T21*Gam1hat*invT12 ...
          + T22z*Gam11invl*T11hat*Gam1hat*(invT11hat*invT22z-invT12)...
  - T21*Gam1hat*invT11hat*Gam11invr*(Gam2hatei*T11hat*Gam1hat*invT12+invT22z));


   Phi22_Phi123=real(T21*Phi1hat*invT12-Gam21Gam11inv3*T11*Phi1hat*invT12...
      -T21*Gam1hat*invT11hat*Gam11invr*[Phi2hat*invT22; zeros(s4,n)]...
      +T22z*Gam11invl*T11hat*Gam1hat*invT11hat*[Phi2hat*invT22; zeros(s4,n)]);

   Om12_Phi123=real( T11*Omega1hat*invT12 -T12*Omega2hat*invT22...
      -T11*Phi1hat*invT11hat*Gam2hatei*Gam11invl*T11hat*Phi1hat*invT12...
         +[T12*Phi2hat zeros(n,s4)]*Gam11invl...
         *T11hat*(-Phi1hat*invT12+Gam1hat*invT11hat(:,1:s3)*Phi2hat*invT22)...
      -T11*Phi1hat*invT11hat*Gam11invr*[Phi2hat*invT22; zeros(s4,n)]);

%   norm(Gam11invGam123-Gam11invGam12)
%   norm(Gam11invPhi123-Gam11invPhi12)
%   norm(Gam21Gam11inv3-Gam21Gam11inv)
%   norm(ad3-ad)
%   norm(Phi22_Phi123-Phi22_Phi12)
%   norm(Om12_Phi123-Om12_Phi12)
%   norm(Gam11invGam123-Gam11invGam123')

   Gam11invGam12=Gam11invGam123;
   Gam11invPhi12=Gam11invPhi123;
   Gam21Gam11inv=Gam21Gam11inv3;
   ad=ad3;
   Phi22_Phi12=Phi22_Phi123;
   Om12_Phi12=Om12_Phi123;
end; % if s3>0
% construct bd1
[uu,sig]=schur(Gam21Gam11inv);
sig=(diag(sig));
maxsig=max(sig);
if any(sig<-1e-6*maxsig),
     soln=0;
     return;
  end;
ipos=find(sig>(1e-14)*maxsig);
bd1=uu(:,ipos)*diag(sqrt(sig(ipos)));

%construct bd2

bd2=Phi22_Phi12*b2;

%construct cd1 and dd12

[uu,sig]=schur([-Gam11invGam12 -Gam11invPhi12*b2;...
                (-Gam11invPhi12*b2)', b2'*Om12_Phi12*b2]);
sig=(diag(sig));
maxsig=max(sig);
if any(sig<-1e-6*maxsig),
     soln=0;
     return;
  end;
ipos=find(sig>(1e-14)*maxsig);
cd1=diag(sqrt(sig(ipos)))*uu(1:n,ipos)';
dd12=diag(sqrt(sig(ipos)))*uu(n+1:max(size(uu)),ipos)';

[row1,col2]=size(dd12);
row2=length(c2(:,1)); col1=length(bd1(1,:));


dsdsys=pck(ad,[bd1 bd2/sqrt(h)],[cd1;c2*sqrt(h)], ...
             [zeros(row1,col1) dd12/sqrt(h); zeros(row2,col1+col2)]);

%construct delay augmented system

if delay >0,
        ndel=delay*row2;
        sysdel=pck([zeros(ndel,row2) eye(ndel,ndel-row2)],...
          [zeros(ndel-row2,row2);eye(row2)],eye(row2,ndel),zeros(row2,row2));
	dsdsys=mmult(daug(eye(row1),sysdel),dsdsys);
 end
