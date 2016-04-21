function [ar,g1x,g1y,g2x,g2y,g3x,g3y]=pdetrg(p,t)
%PDETRG Triangle geometry data.
%
%       [AR,A1,A2,A3]=PDETRG(P,T) returns the area of each triangle in AR
%       and half of the negative cotangent of each angle in A1, A2, and A3.
%
%       [AR,G1X,G1Y,G2X,G2Y,G3X,G3Y]=PDETRG(P,T) returns the area and the
%       gradient components of the triangle base functions.
%
%       The geometry of the PDE problem is given by the triangle data P
%       and T. Details under INITMESH.

%       A. Nordmark 4-25-94, AN 8-01-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:21 $

% Corner point indices
a1=t(1,:);
a2=t(2,:);
a3=t(3,:);

% Triangle sides
r23x=p(1,a3)-p(1,a2);
r23y=p(2,a3)-p(2,a2);
r31x=p(1,a1)-p(1,a3);
r31y=p(2,a1)-p(2,a3);
r12x=p(1,a2)-p(1,a1);
r12y=p(2,a2)-p(2,a1);

% Area
ar=abs(r31x.*r23y-r31y.*r23x)/2;

if nargout==4,
  a1=(r12x.*r31x+r12y.*r31y);
  a2=(r23x.*r12x+r23y.*r12y);
  a3=(r31x.*r23x+r31y.*r23y);
  g1x=0.25*a1./ar;
  g1y=0.25*a2./ar;
  g2x=0.25*a3./ar;
else
  g1x=-0.5*r23y./ar;
  g1y=0.5*r23x./ar;
  g2x=-0.5*r31y./ar;
  g2y=0.5*r31x./ar;
  g3x=-0.5*r12y./ar;
  g3y=0.5*r12x./ar;
end

