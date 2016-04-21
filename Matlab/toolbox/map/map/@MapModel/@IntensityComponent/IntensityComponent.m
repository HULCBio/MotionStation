function h = IntensityComponent(R,I)
%INTENSITYCOMPONENT Constructor for a RGB component.
%
%   INTENSITYCOMPONENT(R,I) constructs an object to store a spatially referenced
%   IntensityImage from the referencing matrix R and the image I.  An intensity
%   image is a data matrix, I, whose values represent intensities within some
%   range. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:06 $

h = MapModel.IntensityComponent;

if ndims(I) ~= 2
  error('I must be a M-by-N data array.');
end

h.ReferenceMatrix = R;
h.ImageData = I;
h.BoundingBox = MapModel.BoundingBox(mapbbox(R,size(I)));
