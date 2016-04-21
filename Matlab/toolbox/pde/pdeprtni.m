function un=pdeprtni(p,t,ut)
%PDEPRTNI Interpolate from triangle data midpoints to node data.
%
%       UN=PDEPRTNI(P,T,UT) gives linearly interpolated values
%       at node point from the values at triangle mid points.
%
%       The geometry of the PDE problem is given by the triangle data P
%       and T. Details under INITMESH.
%
%       Let N be the dimension of the PDE system, and NP the number of
%       node points and NT the number of triangles. The components
%       of triangle data in UT are stored as N rows of length NT.
%       The components of the node data are stored in UN as N columns
%       of length NP.
%
%       See also ASSEMPDE, INITMESH, PDEINTRP

%       A. Nordmark 12-14-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:43 $

np=size(p,2);
nt=size(t,2);

if size(ut,2) ~= nt
  error('PDE:pdeprtni:NumColsUt', 'Wrong number of columns in ut.');
end

A=sparse(t(1:3,:),ones(3,1)*(1:nt),1,np,nt);
B=sparse(1:np,1:np,1./sum(A.'),np,np);
un=B*A*(ut.');

