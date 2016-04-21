function bbox = getBoundingBox(this)
%GETBOUNDINGBOX Get the bounding box of a component.
%
%  BBOX = GETBOUNDINGBOX returns the bounding box of the component, 2-by-2 (of
%  class double). BBOX is a mapmodel.BoundingBox object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:56 $

bbox = this.BoundingBox;



