function h=pdegplot(g)
%PDEGPLOT Plot a PDE geometry specification.
%
%       PDEGPLOT(G) plots the boundary segments specified by G.
%       The internal boundaries are plotted.
%
%       H=PDEGPLOT(G) returns handles to the plotted axes objects.
%
%       G describes the geometry of the PDE problem. G can
%       either be a Decomposed Geometry Matrix or the name of Geometry
%       M-file. See either DECSG or PDEGEOM for details.
%
%       See also PDEGEOM

%       A. Nordmark 4-26-94, LL 1-31-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:15 $

nbs=pdeigeom(g);
d=pdeigeom(g,1:nbs);

% Number of point on a segment
n=50;

X=[];
Y=[];
for i=1:nbs,
  s=linspace(d(1,i),d(2,i),n);
  [x1,y1]=pdeigeom(g,i,s);
  X=[X x1 NaN];
  Y=[Y y1 NaN];
end

hh=plot(X,Y);

if nargout==1
  h=hh;
end

