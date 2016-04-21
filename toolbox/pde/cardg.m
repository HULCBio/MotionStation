function [x,y]=cardg(bs,s)
%CARDG Geometry File defining the geometry of a cardioid.

%       L. Langemyr 1-27-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/10/21 12:26:01 $

nbs=4;

if nargin==0
  x=nbs;
  return
end

dl=[    0       pi/2    pi      3*pi/2
        pi/2    pi      3*pi/2  2*pi;
        1       1       1       1
        0       0       0       0];

if nargin==1
  x=dl(:,bs);
  return
end


x=zeros(size(s));
y=zeros(size(s));
[m,n]=size(bs);
if m==1 && n==1,
  bs=bs*ones(size(s)); % expand bs
elseif m~=size(s,1) || n~=size(s,2),
  error('PDE:cardg:SizeBs', 'bs must be scalar or of same size as s.');
end

nth=400;
th=linspace(0,2*pi,nth);
r=2*(1+cos(th));
xt=r.*cos(th);
yt=r.*sin(th);
th=pdearcl(th,[xt;yt],s,0,2*pi);
r=2*(1+cos(th));
x(:)=r.*cos(th);
y(:)=r.*sin(th);


