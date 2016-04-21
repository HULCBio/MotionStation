function [p,t,c,h]=pdevoron(p,t,c,h,x,y,tol,Hmax,Hgrad)
%PDEVORON Add points to triangular mesh.

%       L. Langemyr 11-25-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:11 $

if isempty(c)
  c=pdecrcum(p,t);
end

np=size(p,2);
tp=size(t,2);
p=[p,[x;y]];
t=[t,zeros(4,2*length(x))];
c=[c,zeros(3,2*length(x))];

if size(h,2)>1
  h=[h,zeros(1,length(x))];
end

for l=1:length(x)
  i=find(sqrt((c(1,1:tp)-x(l)).^2+(c(2,1:tp)-y(l)).^2)-c(3,1:tp)<1000*tol);
  M=sparse(t([1 2 3],i),t([2 3 1],i),ones(3,length(i)),np,np);
  M=M-M'>0;
  [j,k]=find(M);

  i2=length(j);
  tp=tp+2;
  i1=[i tp-1 tp];
  if length(i1)~=length(j)
    error('PDE:pdevoron:GeomError', 'Geometry error.');
  end
  t(1,i1)=j';
  t(2,i1)=k';
  t(3,i1)=ones(1,i2)*np+1;
  c(:,i1)=pdecrcum(p,t(:,i1));
  np=np+1;
  if size(h,2)>1
    h(np)=min(Hmax,min(h(j)+(Hgrad-1)*(sqrt((x(l)-p(1,j)).^2+(y(l)-p(2,j)).^2))));
  end
end

