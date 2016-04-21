function h=pdemesh(p,e,t,u)
%PDEMESH Plot a PDE triangular mesh.
%
%       PDEMESH(P,E,T) plots the mesh specified by P, E, and T.
%
%       PDEMESH(P,E,T,U) plots the solution column vector U using
%       a mesh plot.  If U is a column vector, node data is
%       assumed. If U is a row vector, triangle data is assumed.
%       This command plots the solution substantially faster than the
%       PDESURF command.
%
%       H=PDEMESH(P,E,T) additionally returns handles to the plotted
%       axes objects.

%       A. Nordmark 4-26-94, LL 1-30-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:17 $

if nargin==4
  hh=pdeplot(p,e,t,'zdata',u);
else
  hh=pdeplot(p,e,t);
end

if nargout==1
  h=hh;
end

