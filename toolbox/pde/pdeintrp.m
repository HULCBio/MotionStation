function ut=pdeintrp(p,t,un)
%PDEINTRP Interpolate from node data to triangle midpoint data.
%
%       UT=PDEINTRP(P,T,UN) gives linearly interpolated values
%       at triangle midpoints from the values at node points.
%
%       The geometry of the PDE problem is given by the triangle data P
%       and T. Details under INITMESH.
%
%       Let N be the dimension of the PDE system, and NP the number of
%       node points and NT the number of triangles. The components
%       of the node data are stored in UN either as N columns of
%       length NP or as an ordinary solution vector: The first NP values
%       of UN describe the first component, the following NP values
%       of UN describe the second component, and so on.  The components
%       of triangle data are stored in UT as N rows of length NT.
%
%       See also ASSEMPDE, INITMESH, PDEPRTNI

%       A. Nordmark 4-26-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:17 $

np=size(p,2);
nt=size(t,2);

if size(un,2)==1
  N=size(un,1)/np;
  un=reshape(un,np,N);
end

A=sparse(ones(3,1)*(1:nt),t(1:3,:),1,nt,np);
B=sparse(1:nt,1:nt,1./sum(A.'),nt,nt);
ut=(B*A*un).';

