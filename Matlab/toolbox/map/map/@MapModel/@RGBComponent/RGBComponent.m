function this = RGBComponent(R,I,attributes)
%RGBCOMPONENT Constructor for a RGB component.
%
%   RGBCOMPONENT(R,I) constructs an RGBComponent from the referencing matrix R
%   and the RGB image I.  I must be an m-by-n-by-3 data array that defines red,
%   green, and blue color components for each individual pixel.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:15 $

this = MapModel.RGBComponent;

if (ndims(I) ~= 3) || ~isnumeric(I)
  error('I must be an m-by-n-3 numeric data array.');
end

if ~all(size(R) == [3 2]) || ~isnumeric(R)
  error('R must be a 3-by-2 numeric referencing matrix.');
end

this.ReferenceMatrix = R;
this.ImageData = I;
this.BoundingBox = MapModel.BoundingBox(mapbbox(R,size(I)));
this.Attributes = attributes;