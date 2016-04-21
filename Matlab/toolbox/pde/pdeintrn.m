function [k,t]=pdeintrn(p,e,t)
%PDEINTRN Determine interior triangles in a triangular mesh.
%
%       Optionally update t with respect to subdomain number.

%       L. Langemyr 11-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:17 $
if nargout==1
   np=size(p,2);
   i=find(e(6,:));              % turning left from boundary
   E=sparse(e(1,i),e(2,i),ones(1,length(i)),np,np);
   i=find(e(7,:));              % turning right from boundary
   E=E|sparse(e(2,i),e(1,i),ones(1,length(i)),np,np);
   T=sparse(t([1 2 3],:),t([2 3 1],:),ones(3,1)*(1:size(t,2)),np,np);
   [i,j,k]=find(T.*E);
   k1=[];
   k=sort(k);
   k=k(find([1;sign(diff(k))]));
   while length(k1)~=length(k)
      T1=sparse(t([1 2 3],k),t([2 3 1],k),ones(3,length(k)),np,np)-E>0;
      [i,j,k2]=find(T1'.*T);
      k1=k;
      k=sort([k;k2]);
      k=k(find([1;sign(diff(k))]));
   end
else
   np=size(p,2);
   i=find(e(6,:));              % turning left from boundary
   E=sparse(e(1,i),e(2,i),e(6,i),np,np);
   i=find(e(7,:));              % turning right from boundary
   E=E+sparse(e(2,i),e(1,i),e(7,i),np,np);
   T=sparse(t([1 2 3],:),t([2 3 1],:),ones(3,1)*(1:size(t,2)),np,np);
   [i,j,k]=find(T.*sign(E));
   [i,j,s]=find(sign(T).*E);
   k1=[];
   [k,i]=sort(k);
   s=s(i);
   i=[1;sign(diff(k))];
   i=find(i);
   k=k(i);
   s=s(i);
   while length(k1)~=length(k)
      T1=sparse(t([1 2 3],k),t([2 3 1],k),ones(3,length(k)),np,np)-sign(E)>0;
      T1=T1'.*T;
      [i,j,k2]=find(T1);
      S=sparse(t([1 2 3],k),t([2 3 1],k),ones(3,1)*s',np,np);
      [i,j,s2]=find(S'.*sign(T1));
      k1=k;
      [k,i]=sort([k;k2]);
      s=[s;s2];
      s=s(i);
      i=[1;sign(diff(k))];
      i=find(i);
      k=k(i);
      s=s(i);
   end
   t(4,:)=zeros(1,size(t,2));
   t(4,k)=s';
end

