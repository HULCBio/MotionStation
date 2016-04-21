function bbox = getBoundingBox(this)
%GETBOUNDINGBOX Get the bounding box of a component.
%
%  BBOX = GETBOUNDINGBOX returns the bounding box of the component, 2-by-2 (of
%  class double). BBOX contains [lower-left-x,y; upper-right-x,y].

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:03 $

bboxes = zeros(2,2,length(this.Features));
features = this.Features;
for i=1:length(this.Features)
bboxes(:,:,i) = features(i).BoundingBox.getBoxCorners;
end
bbox = MapModel.BoundingBox([min(bboxes(1,:,:),[],3); max(bboxes(2,:,:),[],3)]);





