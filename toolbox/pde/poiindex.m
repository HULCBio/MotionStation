function [n1,n2,h1,h2,i,c,ii,cc]=poiindex(p,e,t,sd)
%POIINDEX Indices of points in canonical ordering for rectangular grid.
%
%       [N1,N2,H1,H2,I,C,II,CC]=POIINDEX(P,E,T,SD) tries to
%       identify a given grid P, E, T in the subdomain SD
%       as an evenly spaced rectangular grid. If the grid
%       is not, N1 is 0 on return. Otherwise N1 and N2
%       are the number of points in the first and second
%       directions, H1 and H2 are the spacings. I and II
%       are of length (N1-2)*(N2-2) and contain
%       indices of interior points. I contains indices of the
%       original mesh, whereas II contains indices of the
%       canonical ordering. C and CC are of length
%       N1*N2-(N1-2)*(N2-2) and contain indices of border
%       points. II and CC are increasing.
%
%       In the canonical ordering, points are numbered from
%       "left to right" and then from "bottom to top". Thus
%       if N1=3 and N2=5, then II=[5 8 11] and
%       CC=[1 2 3 4 6 7 9 10 12 13 14 15].

%       A. Nordmark 10-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:22 $


% Edges bordering our SD
e=e(:,find(e(6,:)==sd | e(7,:)==sd));
% Directions of edges
a=atan2(p(2,e(2,:))-p(2,e(1,:)),p(1,e(2,:))-p(1,e(1,:)));
amin=min(a);
ai=(a-amin)/(pi/2); % Should be integer in 0..3 but
ep=10000*eps; % we compensate for possible roundoff errors.
aii=floor(ai+ep);
if max(abs(ai-aii))>2*ep,
  n1=0;
  return
end
i1=min(find(rem(aii,2)==0)); % An edge
i2=min(find(rem(aii,2)==1)); % An orthogonal edge
h1=norm([p(:,e(2,i1))-p(:,e(1,i1))]); % Length of edge 1
h2=norm([p(:,e(2,i2))-p(:,e(1,i2))]); % Length of edge 2
[ip,cp]=pdesdp(p,e,t,sd);
% Transform to x-y parallel coordinates
pp=[cos(amin) sin(amin);-sin(amin) cos(amin)]*p(:,[ip cp]);
np=size(pp,2);
xmin=min(pp(1,:));
xmax=max(pp(1,:));
ymin=min(pp(2,:));
ymax=max(pp(2,:));
n1=round((xmax-xmin)/h1)+1;
n2=round((ymax-ymin)/h2)+1;
if n1*n2~=np,
  n1=0;
  return
end
% Make the x direction have the largest number of points
if n2>n1,
  tmp=n1;n1=n2;n2=tmp;
  tmp=h1;h1=h2;h2=tmp;
  tmp=xmin;xmin=-ymax;ymax=xmax;xmax=-ymin;ymin=tmp;
  pp=[0 -1;1 0]*pp;
end
pi1=(pp(1,:)-xmin)/h1; % Should be an integer in 0..(n1-1)
pii1=floor(pi1+ep*n1);
if max(abs(pi1-pii1))>2*ep*n1,
  n1=0;
  return
end
pi2=(pp(2,:)-ymin)/h2; % Should be an integer in 0..(n2-1)
pii2=floor(pi2+ep*n2);
if max(abs(pi2-pii2))>2*ep*n2,
  n1=0;
  return
end
ix=1+pii1+n1*pii2;
tmp=zeros(1,np);
tmp(ix)=ones(1,np);
if ~all(tmp),
  n1=0;
  return
end
tmp(ix)=[ip cp];
iii=reshape((1:np)',n1,n2);
ii=iii(2:n1-1,2:n2-1);
ii=ii(:)';
iii=iii(:);
iii(ii(:))=zeros(size(ii(:)));
cc=find(iii)';
i=tmp(ii);
c=tmp(cc);

