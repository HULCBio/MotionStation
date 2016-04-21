function addFeatures(this,shapeData,attributes)
%ADDFEATURES Add features to a VectorComponent.
%
%   Vector components are composed of zero or more features.
%   ADDFEATURE(SHAPEDATA,ATTRIBUTES) adds features to the
%   VectorComponent. SHAPEDATA is an array of Vector Shape Structures. Each
%   feature has coordinates SHAPEDATA.X, SHAPDATA.Y, a bounding box
%   SHAPEDATA.BoundingBox and attributes in the corresponding element of the
%   array of structures, ATTRIBUTES.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:14:02 $

this.preallocateFeatureArray(length(shapeData));

if ~isempty(attributes)
  if ~ isequal(length(shapeData),length(attributes))
    error(sprintf(['The length of the array of attribute structures is not equal to ' ...
           'the \nnumber of features. There must be an attribute, or set ' ...
           'of attributes,\nfor each feature.']));
  end
end

temp = this.Features;
for i=1:length(shapeData)
  if isempty(attributes)
    attribute = [];
  else
    attribute = attributes(i);
  end
  temp(i) = MapModel.feature(shapeData(i).X,shapeData(i).Y,...
                             shapeData(i).BoundingBox, ...
                             attribute);
end
this.Features = temp;
