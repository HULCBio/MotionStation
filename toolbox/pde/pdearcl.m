function pp=pdearcl(p,xy,s,s0,s1)
%PDEARCL Interpolation between parametric representation and arc length.
%
%       PP=PDEARCL(P,XY,S,S0,S1) returns parameter values for a
%       parametrized curve corresponding to a given set of
%       arc length values.
%
%       P is a monotone row vector of parameter values and
%       XY is a matrix with two rows giving the corresponding
%       points on the curve.
%
%       The first point of the curve is given the arc length value
%       S0 and the last point the value S1.
%
%       On return, PP will contain parameter values corresponding
%       to the arc length values specified in S.
%
%       The arc length values S, S0, and S1, need only be proportional
%       to arc length.
%
%       See also: PDEGEOM, PDEIGEOM

%       A. Nordmark 2-6-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:13 $

np=length(p);

dal=sqrt((xy(1,2:np)-xy(1,1:np-1)).^2+ ...
         (xy(2,2:np)-xy(2,1:np-1)).^2);
al=[0 cumsum(dal)];
tl=al(np);
s=s(:);
sal=tl*(s-s0)/(s1-s0);
pp=interp1(al,p,sal)';

