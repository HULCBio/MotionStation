function ntl=pdeent(t,it)
%PDEENT Indices of triangles neighboring a given set of triangles.
%
%       NTL=PDEENT(T,TL). Given triangle data T and a list of
%       triangle indices TL, NTL contains indices of the triangles
%       in TL and their immediate neighbors.

%       A. Nordmark 6-14-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:16 $

if nargin ~=2,
  error('PDE:pdeent:nargin', 'Two input arguments needed in pdeent.');
end

nt=size(t,2);
np=max(max(t(1:3,:)));

it1=ones(1,nt);
it1(it)=zeros(size(it));
it1=find(it1); % Triangles not in the list
ip1=t(1,it)';
ip2=t(2,it)';
ip3=t(3,it)';

% Make a connectivity matrix.
A=sparse(ip1,ip2,1,np,np);
A=A+sparse(ip2,ip3,1,np,np);
A=A+sparse(ip3,ip1,1,np,np);

ntl=zeros(1,nnz(A-A')); % a slight overestimate
nnt=0;
% A triangle is a neighbor if it is not in the set
% and it as got a REVERSED edge in common with a triangle in the set.
% Here we rely on triangles having positive orientation.
% This code should be vectorized as soon as A(ix) is efficiently implemented.
for i=1:length(it1),
  if A(t(2,it1(i)),t(1,it1(i))) | ...
     A(t(3,it1(i)),t(2,it1(i))) | ...
     A(t(1,it1(i)),t(3,it1(i))),
    nnt=nnt+1;
    ntl(nnt)=it1(i);
  end
end
ntl=sort([it ntl(1:nnt)]);

