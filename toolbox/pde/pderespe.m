function [p,e,t,c,h]=pderespe(g,p,e,t,c,h,tol,tol2,Hmax,Hgrad)
%PDERESPE   Enforce additional points on boundary until edge is respected.

%       L. Langemyr 11-25-94, LL 7-18-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:50 $

np=size(p,2);
T=sparse(t([1 2 3],:),t([2 3 1],:),ones(3,size(t,2)),np,np);
T=T|T';
E=sparse(e(1,:),e(2,:),ones(1,size(e,2)),np,np);
I=sparse(e(1,:),e(2,:),1:size(e,2),np,np);
M=T-E<0;
[j,k,i]=find(M.*I);

if isempty(j), return, end

for kk1=1:5

  % First attempt - subdivide non respected edges four times

  for kk2=1:3

  ne=size(e,2);
  m=(e(3,i)+e(4,i))/2;
  [x,y]=pdeigeom(g,e(5,i),m);
  e(:,ne+1:ne+length(i))=e(:,i);
  e(2,i)=np+1:np+length(i);
  e(1,ne+1:ne+length(i))=np+1:np+length(i);
  e(4,i)=m;
  e(3,ne+1:ne+length(i))=m;
  [p,t,c,h]=pdevoron(p,t,c,h,x,y,tol,Hmax,Hgrad);
  np=size(p,2);
  T=sparse(t([1 2 3],:),t([2 3 1],:),ones(3,size(t,2)),np,np);
  T=T|T';
  E=sparse(e(1,:),e(2,:),ones(1,size(e,2)),np,np);
  I=sparse(e(1,:),e(2,:),1:size(e,2),np,np);
  M=T-E<0;
  [j,k,i]=find(M.*I);

  if isempty(j), return, end
  end

  % Second attempt - subdivide non respected edges twice

  for kk2=1:2

  ex1=p(1,e(1,i)); ex2=p(1,e(2,i));
  ey1=p(2,e(1,i)); ey2=p(2,e(2,i));
  lx1=[p(1,t(1,:)) p(1,t(2,:)) p(1,t(3,:))];
  lx2=[p(1,t(2,:)) p(1,t(3,:)) p(1,t(1,:))];
  ly1=[p(2,t(1,:)) p(2,t(2,:)) p(2,t(3,:))];
  ly2=[p(2,t(2,:)) p(2,t(3,:)) p(2,t(1,:))];

  l1=length(i);
  l2=length(lx1);
  i1=(1:l1)'*ones(1,l2); i1=i1(:)';
  i2=ones(l1,1)*(1:l2); i2=i2(:)';

  dx1=ex2(i1)-ex1(i1); dy1=ey2(i1)-ey1(i1);
  dx2=lx2(i2)-lx1(i2); dy2=ly2(i2)-ly1(i2);
  dt=dx1.*dy2-dx2.*dy1;
  ii=find(abs(dt)>tol2);        % check for intersecting lines
  i1=i1(ii);
  i2=i2(ii);

  hx=dy1(ii).*ex1(i1)-dx1(ii).*ey1(i1);
  hy=dy2(ii).*lx1(i2)-dx2(ii).*ly1(i2);
  xi=(dx1(ii).*hy-dx2(ii).*hx)./dt(ii);
  yi=(hy.*dy1(ii)-hx.*dy2(ii))./dt(ii);
  l1=find(((xi-min(ex1(i1),ex2(i1))>tol & xi-max(ex1(i1),ex2(i1))<-tol) | ...
           (yi-min(ey1(i1),ey2(i1))>tol & yi-max(ey1(i1),ey2(i1))<-tol)) & ...
          ((xi-min(lx1(i2),lx2(i2))>tol & xi-max(lx1(i2),lx2(i2))<-tol) | ...
           (yi-min(ly1(i2),ly2(i2))>tol & yi-max(ly1(i2),ly2(i2))<-tol)));

  kk=[];
  mm=[];
  ss=[];

  ne=size(e,2);
  np=size(p,2);

  for jj=i(:)'
    jjj=find(jj==i(i1(l1)));
    x=xi(l1(jjj));
    y=yi(l1(jjj));

    if ~isempty(x)
      [x,ij]=sort(x);
      y=y(ij);
      ij=1; nj=length(x); del=[];
      while ij<nj
        kj=find(abs(x-x(ij))<tol);
        y(kj)=sort(y(kj));
        ij=ij+length(kj);
      end

      del=find(abs(x(1:nj-1)-x(2:nj))<tol & abs(y(1:nj-1)-y(2:nj))<tol);
      x(del)=[];
      y(del)=[];
      s=sqrt(((x-p(1,e(1,jj))).^2+(y-p(2,e(1,jj))).^2) ./ ...
             ((p(1,e(2,jj))-p(1,e(1,jj))).^2+(p(2,e(2,jj))-p(2,e(1,jj))).^2));

      s=s.*(e(4,jj)-e(3,jj))+e(3,jj);

      [s,ind]=sort(s);
      x=x(ind);
      y=y(ind);

      nn=length(x);
      kk=[kk e(5,jj)*ones(1,nn)];
      mm=[mm s];

      e(:,ne+1:ne+nn)=e(:,jj)*ones(1,nn);
      e(2,jj)=np+1;
      e(1,ne+1:ne+nn)=np+1:np+nn;
      e(2,ne+1:ne+nn-1)=np+2:np+nn;
      e(4,jj)=s(1);
      e(4,ne+1:ne+nn-1)=s(2:nn);
      e(3,ne+1:ne+nn)=s;

      ne=ne+nn;
      np=np+nn;
    end
  end

  [x,y]=pdeigeom(g,kk,mm);
  [p,t,c,h]=pdevoron(p,t,c,h,x,y,tol,Hmax,Hgrad);
  np=size(p,2);
  T=sparse(t([1 2 3],:),t([2 3 1],:),ones(3,size(t,2)),np,np);
  T=T|T';
  E=sparse(e(1,:),e(2,:),ones(1,size(e,2)),np,np);
  I=sparse(e(1,:),e(2,:),1:size(e,2),np,np);
  M=T-E<0;
  [j,k,i]=find(M.*I);
  if isempty(j), return, end
  end

end

error('PDE:pderespe:InitmeshError', 'fatal error in initmesh.');

