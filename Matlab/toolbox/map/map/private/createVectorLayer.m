function [layer,component] = createVectorLayer(S, name)
%CREATEVECTORLAYER Create a vector layer from a geographic data structure.
%
%   [LAYER, COMPONENT] = CREATEVECTORLAYER(S, NAME) creates a layer, LAYER,
%   and a compoment, COMPONENT, given a geographic data structure, S, and the 
%   layer name, NAME.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:58:06 $

attributes = geoattribstruct(S);
if ~isempty(attributes)
  attrnames = fieldnames(attributes);

  % add Index to the geographic data struct as the 
  % the last attribute, if it does not exist.
  if isempty(strmatch('index',lower(attrnames),'exact'))
     attrnames = [attrnames; {'INDEX'}];
     indexNums = num2cell(1:length(attributes));
     [attributes(1:length(indexNums)).INDEX] = deal(indexNums{:});
  end
else
  attrnames = '';
end

% Assume only one Geometry type per structure.
type = S(1).Geometry;
switch lower(type)
  case {'point', 'multipoint'}
     layer = MapModel.PointLayer(name);
     component = MapModel.PointComponent(attrnames);
  case 'line'
     layer = MapModel.LineLayer(name);
     component = MapModel.LineComponent(attrnames);
  case 'polygon'
     layer = MapModel.PolygonLayer(name);
     component = MapModel.PolygonComponent(attrnames);
  otherwise
     eid = sprintf('%s:%s:invalidGeometryType', getcomp, mfilename);
     msg = sprintf('%s%s%s', ...
                   'Geometry type ''', type,''' is not supported.');
     error(eid, '%s',msg)
end
component.preallocateFeatureArray(length(S));
component.addFeatures(S,attributes);
layer.addComponent(component);
