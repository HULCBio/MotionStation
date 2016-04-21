function h = plotpair(hndl)
% Returns instance of @plotpair class.
%
%   H = PLOTARRAY(AXHANDLE) creates a 2-by-1 plot array using 
%   the HG axes instances supplied in AXHANDLE.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:25 $

h = ctrluis.plotpair;
hndl = handle(hndl);

% Create missing axes
if length(hndl)==1
   hndl = [hndl ; ...
         handle(axes('Parent',hndl.Parent,'Visible','off','ContentsVisible','off'))];
end
h.Axes = hndl(:);

% Geometry
% VerticalGap: vertical spacing in pixels
% HeightRatio: relative heights of 1st and 2nd axes (sum = 1)
g = h.Geometry;
g.VerticalGap = 14;
g.HeightRatio = [.53 .47];
h.Geometry = g;

% Row and column visibility
h.ColumnVisible = true;
h.RowVisible = true(2,1);
h.Position = hndl(1).Position;

% REVISIT: Make axes a bit smaller than plot area so that SUBPLOT does not delete hidden
% phase axes in BODEMAG (see geck 122758)
Pos = h.Position;
set(hndl,'Position',[Pos(1:2) 0.5*Pos(3:4)])

