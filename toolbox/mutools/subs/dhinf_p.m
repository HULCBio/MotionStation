%  function F=dhinf_p(sys,nmeas,ncon,epm1)
%
%  For a discrete time system calculate whether there is
%   a pole near to z=-1 and if so find an output feedback gain, F,
%   so that the poles move a small distance from -1.  EPMR1 gives
%   a tolerance for how close to -1,  in  MIN(SVD(a+eye))<EPMR1.
%   Used by DHFSYN.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function F=dhinf_p(sys,nmeas,ncon,epm1)

if nargin==0,
    disp('usage: F=dhinf_p(sys,nmeas,ncon,epm1'),
    return;
  end;

if nargin<3,
    disp('usage: F=dhinf_p(sys,nmeas,ncon,epm1'),
    error('incorrect number of input arguments'),
    return;
  end;

if nargin==3,
    epm1=1e-5;
  end;

[type,p,m,n]=minfo(sys);

if type~='syst',
       disp('usage: F=dhinf_p(sys,nmeas,ncon,epm1'),
       error('SYS must be of type SYSTEM'),
       return,
  end;

[a,b,c,d]=unpck(sys);
d22=d(p-nmeas+1:p,m-ncon+1:m);

[u,sig,v]=svd(a+eye(n));
r=sum(diag(sig)<epm1);
if r==0,
     F=zeros(ncon,nmeas);
  else
     b22=u(:,n-r+1:n)'*b(:,m-ncon+1:m);
     c22=c(p-nmeas+1:p,:)*v(:,n-r+1:n);
     F1=(b22\eye(r))/c22;
     nmd22=norm(d22);
     nmF1=norm(F1);
     alphamax=5*epm1;
     if alphamax*nmd22*nmF1>0.5,
          alphamax=0.5/(nmd22*nmF1)
       end; %if alphamax
     largest=0;
     for alpha=-alphamax:alphamax/5:alphamax,
         msv=svd(eye(n)+a+alpha*b(:,m-ncon+1:m)*F1*c(p-nmeas+1:p,:));
         if msv(n)>= largest,
            bestalpha=alpha; largest=msv(n);
           end;
       end; %for alpha=epm1
     F2=bestalpha*F1;
     F=F2/(eye(nmeas)+d22*F2);
end; % if r==0,
%
%