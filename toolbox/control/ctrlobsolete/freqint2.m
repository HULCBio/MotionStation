function [w]=freqint2(a,b,c,d,npts)
%FREQINT2 Auto-ranging algorithm for Nyquist and Nichols plots.
%   W=FREQINT2(A,B,C,D,Npts)
%   W=FREQINT2(NUM,DEN,Npts)

%   Andy Grace  7-6-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:26 $

% Generate more points where graph is changing rapidly.
% Calculate points based on eigenvalues and transmission zeros. 

[na,ma] = size(a);

if (nargin==3)&(na==1),         % Transfer function form
  npts=c;
  ep=sort([roots(b);roots(a)]);
  n=length(a);
  if n==length(b)
    d=1;
  else
    d=0;
  end
else                % State space form
  if (nargin==3), npts=c; [a,b,c,d] = tf2ss(a,b); end
  z=tzero(a,b,c,d);
  z=z(abs(z)<1.e6);     % Ignore zeros greater than 1.e6
  ep=sort([eig(a);z]);
end

[ny,nu] = size(d);  if ny*nu==0, w=[]; return, end

if isempty(ep), ep=-1000; end

ez=[ep(find(imag(ep)>=0))];
integ = real(ez)<eps; % Any integrators or poles on imaginary axis
ez = ez - 1e-5*(integ) + sqrt(-1)*eps*integ;
[dum,ind]=sort(-abs(real(ez)));
z=[];
npts2=25-6*length(ind);

for i=ind'
  npts2=npts2+6;
  npts3=max([7+6*(d(1)~=0),npts2]);
  arez=abs(real(ez(i))); iez=imag(ez(i));
  r1=max([iez-8*arez,1/10*arez]);
  r2=iez+8*arez;
  indr=find(z<=r2&z>=r1);
  npts=npts3*(1+(iez>0))+length(indr);
  if 1.5*iez>arez    
    f1=iez+exp(-1.5:6/npts:4)*arez-exp(-1.5)*arez;
    f2=2*iez-f1; 
    f=[f1,f2(find(f2>r1&f2~=iez))];
  else
    f=logspace(log10(r1),log10(r2),npts);
  end
  z=[z,f];
  z(indr)=[];
end

z=sort(z);
mz=z(length(z));
f=logspace(log10(mz),log10(6*mz),10);
z=[linspace(0, 0.95*min(z),10),z,f(2:10),20*mz];
if any(abs(real(ep))<eps) 
    z = z(2:length(z));
end
w=z(:);

% end freqint2
