function addFeature(this,shapeData,attributes)
%ADDFEATURE Add a feature to the line component.
%
%   Point components are composed of zero or more of features.
%   ADDFEATURE(SHAPEDATA,ATTRIBUTES) adds a feature to the point component. The
%   feature has coordinates SHAPEDATA.X, SHAPEDATA.Y, and attributes in the
%   structure ATTRIBUTES.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:15 $

xMin = min(shapeData.X);
yMin = min(shapeData.Y);
xMax = max(shapeData.X);
yMax = max(shapeData.Y);
boundingBox = [xMin,yMin,diff([xMin,xMax]),diff([yMin,yMax])];
this.Features = [this.Features,...
                 MapModel.feature(shapeData.X,shapeData.Y,...
                                  boundingBox,attributes)];
