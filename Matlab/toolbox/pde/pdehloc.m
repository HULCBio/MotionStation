function h=pdehloc(p,e,t,Hmax,Hmin,Hgrad)
%PDEHLOC Determine local triangle size.

%       L. Langemyr, A. Nordmark 8-24-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.10 $  $Date: 2001/02/09 17:03:16 $

t=t(1:3,:);

np=size(p,2);
ne=size(e,2);
nt=size(t,2);

T=sparse(t([2 3 1],:),t([3 1 2],:),reshape(1:3*nt,nt,3)',np,np);
E=sparse(e(1,:),e(2,:),1:ne,np,np);
E=E+E';
M=sign(T)&sign(E);

[i,j,k1]=find(M.*E);
[i,j,k2]=find(M.*T);

P=sparse(k1,rem(k2-1,nt)+1,fix((k2-1)/nt)+1,ne,nt);
i=find(sum(sign(P))==1);
if isempty(i)
   i=[];
   j1=[];
   j2=[];
   j3=[];
else
   j1=sum(P(:,i));
   j2=rem(j1,3)+1;
   j3=rem(j1+1,3)+1;
end

it1=t(j1+3*(i-1));
it2=t(j2+3*(i-1));
it3=t(j3+3*(i-1));

vx1=p(1,it3)-p(1,it2);
vy1=p(2,it3)-p(2,it2);
vx2=p(1,it1)-p(1,it3);
vy2=p(2,it1)-p(2,it3);
vx3=p(1,it2)-p(1,it1);
vy3=p(2,it2)-p(2,it1);

if nargin==3
  % compute angle
  h=zeros(2,nt);
  h(1,i)=acos((vx2.*vx3+vy2.*vy3)./sqrt(vx2.^2+vy2.^2)./sqrt(vx3.^2+vy3.^2));
else
  h=abs(vx2.*vy3-vx3.*vy2)./sqrt(vx1.^2+vy1.^2);
  ii=find((vx1.*vx2+vy1.*vy2<=0)&(vx1.*vx3+vy1.*vy3<=0));
  A=sparse(it1(ii),i(ii),1./h(ii),np,nt);
  iii=max(A');
  ii=find(iii==0);
  iii(ii)=1/Hmax*ones(size(iii(ii)));
  h=min(1./iii,Hmax);

  if all(h>=Hmax) & Hmin>=Hmax
    return
  end
end

i=find(sum(sign(P))==2);
if isempty(i)
   i=[];
   j1=[];
   j2=[];
   j3=[];
else
   j1=6-sum(P(:,i));
   j2=rem(j1,3)+1;
   j3=rem(j1+1,3)+1;
end

it1=t(j1+3*(i-1));
it2=t(j2+3*(i-1));
it3=t(j3+3*(i-1));

vx1=p(1,it3)-p(1,it2);
vy1=p(2,it3)-p(2,it2);
vx2=p(1,it1)-p(1,it3);
vy2=p(2,it1)-p(2,it3);
vx3=p(1,it2)-p(1,it1);
vy3=p(2,it2)-p(2,it1);

if nargin==3
  h(1:2,i)=[
    acos((vx1.*vx2+vy1.*vy2)./sqrt(vx1.^2+vy1.^2)./sqrt(vx2.^2+vy2.^2))
    acos((vx3.*vx1+vy3.*vy1)./sqrt(vx3.^2+vy3.^2)./sqrt(vx1.^2+vy1.^2))];
  return
end

ii=find(abs((vx2.*vx3+vy2.*vy3))>cos(2*pi/3)*...
        sqrt(vx2.^2+vy2.^2).*sqrt(vx3.^2+vy3.^2) & ...
        sqrt(vx1.^2+vy1.^2)<Hmax);
TT=sparse(it2(ii),it3(ii),1,np,np);

T=sparse(t([1 2 3],:),t([2 3 1],:),1,np,np);
[I,J]=find(sign(T+T')>sign(TT+TT'));

D=sqrt((p(1,I)-p(1,J)).^2+(p(2,I)-p(2,J)).^2);
iii=max(sparse(I,J,1./D,np,np));
iii(1:4)=1/Hmax*ones(1,4);
h=min(h,min(1./iii,Hmax));

h1=Hmax;
while any(h1~=h)
  hp=h(I)+(Hgrad-1)*D;
  h1=h;
  iii=max(sparse(I,J,1./hp,np,np));
  iii(1:4)=1/Hmax*ones(1,4);
  h=min(1./iii,h);
end

