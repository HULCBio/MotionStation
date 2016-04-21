function str = ssfrupd(par,struc)
%SSFRUPD   Updates ABCD matrices for free parameterizations

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:47 $

Qperp=struc.Qperp;
a=struc.a;a0=a;
b=struc.b;b0=b;
c=struc.c;c0=c;
d=struc.d;d0=d;
k=struc.k;k0=k;
nk=struc.nk;
x0=struc.x0;x00=x0;
[n,m]=size(b);
[p,n]=size(c);
dkx=struc.dkx;
 
par = Qperp *par;
idx = 1; len = n*n; 
a0(:) = par(idx:len);
idx = idx+len; len = n*m;
b0(:) = par(idx:idx+len-1);
if dkx(2),
   idx = idx+len; len = n*p;
   k0(:) = par(idx:idx+len-1);
else
   k0(:) = zeros(n*p,1);
end
idx = idx+len; len = n*p;
c0(:) = par(idx:idx+len-1);
d0(:) = zeros(p*m,1);
if dkx(1),
   ds = ones(p,1)*(nk==0);
   idx = idx+len; len = sum(nk==0)*p;
   indtd = [1:m*p].*ds(:)';
   indtd = indtd(find(indtd>0));
   d0(indtd) = par(idx:idx+len-1);
end
if dkx(3), 
   idx = idx+len; len = n;
   x00(:) = par(idx:idx+len-1);
else
   x00(:) = zeros(n,1);
end;
str=struc;
str.a=a0+a;
str.b=b0+b;
str.c=c0+c;
str.d=d0+d;
str.k=k0+k;
str.x0=x00+x0;
