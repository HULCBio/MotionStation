function [p,e,t]=pdermpnt(p,e,t)
%PDERMPNT Remove points that are not used in triangular mesh.

%       L. Langemyr 1-10-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:20 $


i=t(1:3,:); i=i(:);
j=zeros(1,size(p,2));
j(i)=ones(size(i));
k=cumsum(j);

j=find(j);
p=p(:,j);
e(1:2,:)=reshape(k(e(1:2,:)),2,size(e,2));
t(1:3,:)=reshape(k(t(1:3,:)),3,size(t,2));

