function importFromFile(this,filename)
%IMPORTFROMFILE
%
%   importFromFile(FILENAME)

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:57:01 $

this.setCursor('wait');
map = this.getMap;
[path,name,ext] = fileparts(filename);
this.setCurrentPath(filename);

[dataArgs,displayType,info] = mapgate('readMapData',[],filename);

switch lower(ext)

 case {'.tif','.tiff','.jpg','.jpeg','.png'}
  
  if length(dataArgs) == 2
    %cmap is empty because readMapData rips it out so we need to 
    % explicitly pass it to the createLayer subfunction
    layer = createLayer(map,name,dataArgs{1},[],dataArgs{2},info);
  else
    layer = createLayer(map,name,dataArgs{:},info);
  end
  
 case {'.shp','.shx','.dbf'}
  shapeData = dataArgs{1};
  % Project the data if needed
  if isfield(shapeData,'Lat') && isfield(shapeData,'Lon')
      %shape = projectGeoStruct([], shape);
      [shapeData.X] = deal(shapeData.Lon);
      [shapeData.Y] = deal(shapeData.Lat);
  end
  [layer, tmp] = mapgate('createVectorLayer', shapeData, name);

 case {'.grd','.ddf'}
  layer = createGridLayer([],dataArgs{2},dataArgs{1},name,'surf');
end
this.addLayer(layer);
this.setCursor('restore');

function layer = createLayer(map,name,I, cmap, R, Iinfo)
if isempty(cmap) && (ndims(I) == 2)  % Intensity Image
  layer = createIntensityLayer(map,R,I,name);
elseif ndims(I) == 3                % RGB Image
  layer = createRGBLayer(map,R,I,name,Iinfo);
else                                % Indexed Image
  rgb = ind2rgb8(I,cmap); 
  layer = createRGBLayer(map,R,rgb,name,Iinfo);
end

function newLayer = createIntensityLayer(map,R,I,name)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.IntensityComponent(R,I);
newLayer.addComponent(newComponent);

function newLayer = createRGBLayer(map,R,I,name,Iinfo)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.RGBComponent(R,I,Iinfo);
newLayer.addComponent(newComponent);

function newLayer = createGridLayer(map,R,Z,name,dispType)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.GriddedComponent(R,Z,dispType);
newLayer.addComponent(newComponent);

