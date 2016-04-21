% function [u,t,k]=orsf(u,a,fl,bord)
%
%  *****  UNTESTED SUBROTUINE  *****
%
% Given a matrix A in real Schur form, ORSF finds
%  T = U'*A*U with U unitary and the eigenvalues of
%  T are ordered to have increasing real parts, when
%  FL = 'o', or if FL = 's' sorted into two groups
%  with the eigenvalues of the first group having
%  real part < BORD. The default value of BORD is zero.
%  K gives the number of poles with real part < BORD.
%
%  See Also: OCSF

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [u,t,k]=orsf(u,a,fl,bord)

jay=sqrt(-1);
[n,m]=size(a);
if n~=m
  disp('A is not square')
  return
end
if (nargin>2)&(fl~='o')&(fl~='s'),
  disp(' usage:  [u,t]=orsf(u,a,fl,bord) with fl=''o'' pr ''s'' ')
  return
end
if nargin<=3, bord=0;end
[u,t]=rsf2csf(u,a);
i=1; while i<n, if imag(t(i,i))==0,i=i+1;
               else t(i+1,i+1)=t(i,i)';i=i+2;end;end %ensures roots exact conj.
if fl=='o',
  ia=1;id=1;ib=n-1;il=1;
  while il~=0,
    il=0;
    for i=ia:id:ib,
      tii=t(i,i);tioio=t(i+1,i+1);
      if real(tii)>real(tioio),
        [s,r]=qr([t(i,i+1);tioio-tii]);
        t(1:i+1,i:i+1)=t(1:i+1,i:i+1)*s;
        t(i:i+1,i:n)=s'*t(i:i+1,i:n);
        u(1:n,i:i+1)=u(1:n,i:i+1)*s;
        t(i:i+1,i:i+1)=[tioio,t(i,i+1);0 tii];
        il=i;
      end;
    end;
    ib=ia;id=-id;ia=il+id;
  end;
end; %if fl=='o'

if fl=='s',
  ia=1;id=1;ib=n-1;il=1;
  while il~=0,
    il=0;
    for i=ia:id:ib,
      tii=t(i,i);tioio=t(i+1,i+1);
      if (real(tii)>=bord) & (real(tioio)<bord),
        [s,r]=qr([t(i,i+1);tioio-tii]);
        t(1:i+1,i:i+1)=t(1:i+1,i:i+1)*s;
        t(i:i+1,i:n)=s'*t(i:i+1,i:n);
        u(1:n,i:i+1)=u(1:n,i:i+1)*s;
        t(i:i+1,i:i+1)=[tioio,t(i,i+1);0 tii];
        il=i;
      end;
    end;
    ib=ia;id=-id;ia=il+id;
  end;
end; %if fl=='s'

% find k
k= max(find(real(diag(t))<bord));
% now regain real form.
i=1;
while i<=n,
  if imag(t(i,i))==0,
     [q,r,e]=qr([real(u(:,i)) imag(u(:,i))]');
     s=jay*q(1,2)+q(2,2);
     u(:,i)=u(:,i)*s;
     if i>1, t(1:i-1,i)=t(1:i-1,i)*s;end
     if i<n, t(i,i+1:n)=s'*t(i,i+1:n);end
     i=i+1;
    else
     [q,r,e]=qr([real(u(:,i:i+1)) imag(u(:,i:i+1))]');
     s=jay*q(1:2,3:4)+q(3:4,3:4);
     t(1:i+1,i:i+1)=t(1:i+1,i:i+1)*s;
     t(i:i+1,i:n)=s'*t(i:i+1,i:n);
     u(1:n,i:i+1)=u(1:n,i:i+1)*s;
     i=i+2;
   end %if imag(t(i,i))==0,
end %while i<=n
u=real(u);t=real(t);
%
%