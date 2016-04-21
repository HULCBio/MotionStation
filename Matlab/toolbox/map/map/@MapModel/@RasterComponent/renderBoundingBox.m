function renderBoundingBox(this,layer,ax)
%RENDERBOUNDINGBOX Draw bounding box 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:57 $

bb = this.getBoundingBox;
box = bb.getClosedBox;
name = layer.getLayerName;

h = MapGraphics.BoundingBox([name '_BoundingBox'],name,box,ax);
