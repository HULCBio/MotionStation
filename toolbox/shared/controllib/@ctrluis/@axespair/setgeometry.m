function setgeometry(h,varargin)
%SETGEOMETRY  Sets grid geometry.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:35 $

% Pass new geometry to @plotpair (no listeners!)
h.Axes.Geometry = h.Geometry;

% Update plot
if h.Axes.Visible
   refresh(h.Axes)
end
