function addFeature(this,shapeData,attributes)
%ADDFEATURE Add a feature to a VectorComponent.
%
%   Vector components are composed of zero or more features.
%   ADDFEATURE(SHAPEDATA,ATTRIBUTES) adds a feature to the VectorComponent. The
%   feature has coordinates SHAPEDATA.X, SHAPDATA.Y, a bounding box
%   SHAPEDATA.BoundingBox and attributes in the structure ATTRIBUTES.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:01 $

this.Features = [this.Features,...
                 MapModel.feature(shapeData.X,shapeData.Y,...
                                  shapeData.BoundingBox,attributes)];
