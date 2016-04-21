function renderBoundingBox(this,ax)
%RENDERBOUNDINGBOX Draw bounding box 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:19 $

if ~this.isempty
  name = this.getLayerName;
  bb = this.getBoundingBox;
  h = bb.render(name,name,ax);
  h.setVisible(this.getShowBoundingBox);
end
