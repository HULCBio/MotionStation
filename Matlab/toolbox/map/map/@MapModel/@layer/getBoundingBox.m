function bbox = getBoundingBox(this)
%GETBOUNDINGBOX Get the bounding box of a layer
%
%  BBOX = GETBOUNDINGBOX returns a BoundingBox object for the layer.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:13 $

if ~this.isempty
  bboxes = zeros(2,2,numel(this.Components));
  for i=1:numel(this.Components)
    bboxes(:,:,i) = this.Components(i).getBoundingBox.getBoxCorners;
  end

  bbox = MapModel.BoundingBox([min(bboxes(1,:,:),[],3); ...
                               max(bboxes(2,:,:),[],3)]);
else
  bbox = MapModel.BoundingBox([0 0; 0 0]);
end
  


