function setgeometry(h,varargin)
%SETGEOMETRY  Sets grid geometry.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:53 $

% Pass new geometry to @plotarray (no listeners!)
h.Axes.Geometry = h.Geometry(1);
if length(h.Geometry)==2 & ~isa(h.Axes.Axes(1),'hg.axes')
   % Specifying the geometry of both major and minor grids
   % Subgrid geometry
   set(h.Axes.Axes,'Geometry',h.Geometry(2))
end

% Update plot
if h.Axes.Visible
   refresh(h.Axes)
end
