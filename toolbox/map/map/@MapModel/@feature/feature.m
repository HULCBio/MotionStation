function h = feature(xdata,ydata,boundingBox,attributes)
% FEATURE Construct a feature object.
%
%   FEATURE(XDATA,YDATA,BOUNDINGBOX,ATTRIBUTES) constructs a feature object
%   with coordinates XDATA, YDATA and attributes ATTRIBUTES. Bounding box
%   must be a position vector [x y width height].

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:21 $

h = MapModel.feature;

if length(xdata) ~= length(ydata)
  error('XDATA and YDATA must be the same length');
end

h.XData = xdata;
h.YData = ydata;

h.BoundingBox = MapModel.BoundingBox(boundingBox);

if ~isempty(attributes)
  h.Attributes = attributes;
else
  h.Attributes = struct([]);
end


