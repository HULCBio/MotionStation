function [hdfObjects, hdfEOSObjects] = buildHDFTree(filename)
import com.mathworks.toolbox.matlab.iofun.*;
% Create a description of an HDF/HDF-EOS file and put it in a JTree.  The
% JTree is put into a JScrollPane.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/04/01 16:12:27 $

import javax.swing.tree.*
import java.awt.*;
import javax.swing.*

hdfEOSObjects = [];

%Create nodes of the tree for HDF objects
info = hdfinfo(filename);
hdfObjects = createFileRoot(info,Importer.HDF);
%Build the rest of the tree
hdfObjects = buildtree(info,hdfObjects);

%Create nodes of the tree for HDF-EOS objects
info = hdfinfo(filename,'eos');
if any([isfield(info,'Grid') isfield(info,'Point') isfield(info,'Swath')])
  hdfEOSObjects = createFileRoot(info,Importer.EOS);
  hdfEOSObjects = buildtree(info,hdfEOSObjects);
end
return;

%=====================================================================
function hdfObjects = createFileRoot(info,type)
import com.mathworks.toolbox.matlab.iofun.*;
[path, shortFilename, ext] = fileparts(info.Filename);

if type == Importer.HDF
  hdfObjects = DataNodeFactory.createHDFNode(info.Filename,...
                                         [shortFilename ext]);
elseif type == Importer.EOS
  hdfObjects = DataNodeFactory.createHDFEOSNode(info.Filename,...
                                            [shortFilename ext]);
end

if isfield(info,'Attributes')
  setNodeAttributes(info.Attributes,hdfObjects);
end

%=====================================================================
function root = buildtree(info,root)
import com.mathworks.toolbox.matlab.iofun.*;
import javax.swing.tree.*
import javax.swing.*

fnames = fieldnames(info);

for i=1:length(fnames)
  switch fnames{i}
   case 'SDS'
    numberOfSDS = length(info.SDS);
    for j=1:numberOfSDS
      SDSnode = createSDSNode(info.SDS(j));
      %Add SDS node to tree
      root.add(SDSnode);
    end
   case 'Vdata'
    numberOfVdata = length(info.Vdata);
    for j=1:numberOfVdata
      Vdatanode = createVdataNode(info.Vdata(j));
      root.add(Vdatanode);
    end
   case 'Vgroup'
    numberOfVgroup = length(info.Vgroup);
    for j=1:numberOfVgroup
      Vgroupnode = createVgroupNode(info,j);
      root.add(Vgroupnode);
    end
   case 'Raster8'
    numberOfRaster8 = length(info.Raster8);
    for j=1:numberOfRaster8
      raster8Node = createRaster8Node(info.Raster8(j));
      root.add(raster8Node);
    end
   case 'Raster24'
    numberOfRaster24 = length(info.Raster24);
    for j=1:numberOfRaster24
      raster24Node = createRaster24Node(info.Raster24(j));
      root.add(raster24Node);
    end
   case 'Grid'
    numberOfGrid = length(info.Grid);
    for j=1:numberOfGrid
      Gridnode = createGridNode(info.Grid(j));
      root.add(Gridnode);
    end
   case 'Point'
    numberOfPoint = length(info.Point);
    for j=1:numberOfPoint
      Pointnode = createPointNode(info.Point(j));
      root.add(Pointnode);
    end
   case 'Swath'
    numberOfSwath = length(info.Swath);
    for j=1:numberOfSwath
      Swathnode = createSwathNode(info.Swath(j));
      root.add(Swathnode);
    end
  end
end
return;

%======================================================================
function SDSNode = createSDSNode(info)
import com.mathworks.toolbox.matlab.iofun.*;
%Create node for a Scientific Data Set

%SDS Attributes
%sdsAttributes = createStandardAttributeArray(info.Attributes);
sdsDimensions = createDimensionsArray(info.Dims);
SDSNode = DataNodeFactory.createSDSNode(info.Filename,...
                                    info.Name,...
                                    sdsDimensions);
SDSNode.setPrecision(char(info.DataType));
setNodeAttributes(info.Attributes,SDSNode);

%SDS Dimensions
%for k=1:length(info.Dims)
%  attributes = createStandardAttributeArray(info.Dims(k).Attributes);
%  diminfo = DimensionInfo(info.Dims(k).Name,info.Dims(k).Size,...
%                          attributes);
%  diminfo = DimensionInfo(info.Dims(k).Name,info.Dims(k).Size,...
%                          length(info.Dims(k).Attributes));
%  setNodeAttributes(info.Dims(k).Attributes,diminfo);
%  SDSNode.addDimensionInfo(diminfo);
%end

%======================================================================
function Vdatanode = createVdataNode(info)
import com.mathworks.toolbox.matlab.iofun.*;

%dataAttributes = createStandardAttributeArray(info.DataAttributes);
%customAttributes(1) = StandardAttribute(ImporterResourceBundle.getString('metadata.class'),...
%                                {info.Class});
%customAttributes(1) = StandardAttribute(ImporterResourceBundle.getString('metadata.numrecords'),...
%                                {info.NumRecords});

% IF/ELSE needed to handle mismatching of data types. [] and java classes can
% not be aggregated.
%if isempty(dataAttributes)
%  attributes = customAttributes;
%else
%  attributes = [customAttributes dataAttributes];
%end
Vdatanode = DataNodeFactory.createVdataNode(info.Filename,...
					info.Name,...
                                        info.NumRecords,...
					{info.Fields.Name});

Vdatanode.addStandardAttribute(ImporterResourceBundle.getString('metadata.class'),...
                       {info.Class});
Vdatanode.addStandardAttribute(ImporterResourceBundle.getString('metadata.numrecords'),...
                       {info.NumRecords});
setNodeAttributes(info.DataAttributes,Vdatanode);

%======================================================================
function Vgroupnode = createVgroupNode(info,i)
import com.mathworks.toolbox.matlab.iofun.*;


Vgroupnode = DataNodeFactory.createDefaultNode(info.Vgroup(i).Filename,...
					   info.Vgroup(i).Name);
Vgroupnode.addStandardAttribute(ImporterResourceBundle.getString('metadata.class'),...
                        {info.Vgroup(i).Class});
%Call buildtree recursively to take care of Vgroups
Vgroupnode = buildtree(info.Vgroup(i),Vgroupnode);

%======================================================================
function raster8Node = createRaster8Node(info)
import com.mathworks.toolbox.matlab.iofun.*;
raster8Node = DataNodeFactory.createRaster8Node(info.Filename,...
					   info.Name,...
                                           8);
raster8Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.width'),...
                         {info.Width});
raster8Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.height'),...
                         {info.Height});
raster8Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.colormap'),...
                         {info.HasPalette});

%======================================================================
function raster24Node = createRaster24Node(info)
import com.mathworks.toolbox.matlab.iofun.*;
raster24Node = DataNodeFactory.createRaster24Node(info.Filename,...
                                            info.Name,...
                                            24);
raster24Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.bitdepth'),...
                          {24});
raster24Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.width'),...
                         {info.Width});
raster24Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.height'),...
                         {info.Height});
raster24Node.addStandardAttribute(ImporterResourceBundle.getString('metadata.width'),...
                          {info.Interlace});

%======================================================================
function GridNode = createGridNode(info)
import com.mathworks.toolbox.matlab.iofun.*;
GridNode = DataNodeFactory.createGridNode(info.Filename,...
				      info.Name,...
				      0);

setNodeAttributes(info.Attributes,GridNode)
%infoAttributes = createNodeAttributes(info.Attributes);

    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.upperleft'),...
              {num2str(info.UpperLeft)});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.lowerright'),...
              {num2str(info.LowerRight)});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.rows'),...
              {info.Rows});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.columns'),...
              {info.Columns});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.projection'),...
              {info.Projection.ProjCode});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.zonecode'),...
              {info.Projection.ZoneCode});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.sphere'),...
              {getSphereFromCode(info.Projection.SphereCode)});
    GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.projparams'),...
              {' '});

setProjectionParams(GridNode,info.Projection.ProjCode,info.Projection.ProjParam);
GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.origin'),...
                      {info.OriginCode});
GridNode.addStandardAttribute(ImporterResourceBundle.getString('metadata.pixregcode'),...
                      {info.PixRegCode});

numberOfFields = length(info.DataFields);
matches = findVerticalSubsets(info);
for k=1:numberOfFields
  if length(matches)>1
    if ~isempty(matches{k,2})
      m = matches(k,2:end);
    else
      m = {};
    end
  else
    m = {};
  end
  
  dimensions = {info.DataFields(k).Dims.Name};
  for i=1:length(dimensions)
    dimensions{i} = ['DIM:' dimensions{i}];
  end
  dataFieldNode(k) = DataNodeFactory.createGridFieldNode(info.Filename,...
                                                    info.Name,...
                                                    info.DataFields(k).Name,...
                                                    length(info.DataFields(k).Dims),...
                                                    [dimensions m]);
  for j=1:length(info.DataFields(k).Dims)
    %    diminfo = DimensionInfo(info.DataFields(k).Dims(j).Name,...
    %                            info.DataFields(k).Dims(j).Size,...
    %                            0);
    diminfo(j) = DimensionInfo(info.DataFields(k).Dims(j).Name,...
                            info.DataFields(k).Dims(j).Size);
  end
  dataFieldNode(k).setDimensions(diminfo);

  
  if isempty(info.DataFields(k).TileDims)
    dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.tiledims'),...
                                  {'No Tiles'});
  else
    dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.tiledims'),...
                                  {num2str(info.DataFields(k).TileDims)});
  end
  
  setNodeAttributes(info.Attributes,dataFieldNode(k));
  
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.upperleft'),...
                                {num2str(info.UpperLeft)});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.lowerright'),...
                                {num2str(info.LowerRight)});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.rows'),...
                                {info.Rows});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.columns'),...
                                {info.Columns});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.projection'),...
                                {info.Projection.ProjCode});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.zonecode'),...
                                {info.Projection.ZoneCode});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.sphere'),...
                                {getSphereFromCode(info.Projection.SphereCode)});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.projparams'),...
                                {' '});
  setProjectionParams(dataFieldNode(k),info.Projection.ProjCode,info.Projection.ProjParam);
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.origin'),...
                                {info.OriginCode});
  dataFieldNode(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.pixregcode'),...
                                {info.PixRegCode});
  GridNode.add(dataFieldNode(k));	
end

%======================================================================
function Pointnode = createPointNode(info)
import com.mathworks.toolbox.matlab.iofun.*;
Pointnode = DataNodeFactory.createDefaultNode(info.Filename,...
					  info.Name);

for k=1:length(info.Level)
  levelnodes(k) = DataNodeFactory.createPointNode(info.Filename,...
                                              info.Name,...
                                              info.Level(k).Name,...
                                              0,...
					      info.Level(k).FieldNames);
  levelnodes(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.numrecords'),...
                             {info.Level(k).NumRecords});
  
  setNodeAttributes(info.Attributes,levelnodes(k));

  Pointnode.add(levelnodes(k));
end

%======================================================================
function Swathnode = createSwathNode(info)
import com.mathworks.toolbox.matlab.iofun.*;
Swathnode = DataNodeFactory.createSwathNode(info.Filename,...
					info.Name,...
                                        0);
numberOfAttributes = length(info.Attributes);

pad = java.lang.String('  ');

if ~isempty(info.MapInfo)
  for i=1:length(info.MapInfo)
    Swathnode.addStandardAttribute(ImporterResourceBundle.getString('metadata.map'),...
                           {info.MapInfo(i).Map(:)'});
    Swathnode.addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.offset')),...
                           {info.MapInfo(i).Offset});
    Swathnode.addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.increment')),...
                           {info.MapInfo(i).Increment});
  end
end
if ~isempty(info.IdxMapInfo)
  for i=1:length(info.IdxMapInfo)
    Swathnode.addStandardAttribute(ImporterResourceBundle.getString('metadata.indexmap'),...
                           {info.IdxMapInfo(i).Map(:)'});
    Swathnode.addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.indexsize')),...
                           {info.IdxMapInfo(i).Size});
  end
end
% Global Attributes
setNodeAttributes(info.Attributes,Swathnode);

DataFields = DataNodeFactory.createDefaultNode(info.Filename,...
					   ImporterResourceBundle.getString('node.datafield'));
                                      
GeolocationFields = DataNodeFactory.createDefaultNode(info.Filename,...
						  ImporterResourceBundle.getString('node.geofield'));

matches = findVerticalSubsets(info);
for k=1:length(info.DataFields)
  if length(matches)>1
    if ~isempty(matches{k,2})
      m = matches(k,2:end);
    else
      m = {};
    end
  else
    m ={};
  end
  
  dimensions = {info.DataFields(k).Dims.Name};
  for i=1:length(dimensions)
    dimensions{i} = ['DIM:' dimensions{i}];
  end
  datafieldnodes(k) = DataNodeFactory.createSwathFieldNode(info.Filename,...
                                                    info.Name,...
                                                    info.DataFields(k).Name,...
                                                    length(info.DataFields(k).Dims),...
                                                    [dimensions m]);
  if ~isempty(info.MapInfo)
    for i=1:length(info.MapInfo)
      datafieldnodes(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.map'),...
                                     {info.MapInfo(i).Map});
      datafieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.offset')),...
                                     {info.MapInfo(i).Offset});
      datafieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.increment')),...
                                     {info.MapInfo(i).Increment});
    end
  end
  
  if ~isempty(info.IdxMapInfo)
    for i=1:length(info.IdxMapInfo)
      datafieldnodes(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.indexmap'),...
                                     {info.IdxMapInfo(i).Map});
      datafieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.indexsize')),...
                                     {info.IdxMapInfo(i).Size});
    end 
  end
  
  setNodeAttributes(info.Attributes,datafieldnodes(k));
  
  for j=1:length(info.DataFields(k).Dims)
        diminfo(j) = DimensionInfo(info.DataFields(k).Dims(j).Name,...
                      info.DataFields(k).Dims(j).Size);
%    diminfo = DimensionInfo(info.DataFields(k).Dims(j).Name,...
%                      info.DataFields(k).Dims(j).Size,...
%                      0);
  end
  datafieldnodes(k).setDimensions(diminfo);
  DataFields.add(datafieldnodes(k));
end

for k=1:length(info.GeolocationFields)
  if length(matches)>1
    if ~isempty(matches{k+length(info.DataFields),2})
      m = matches(k+length(info.DataFields),2:end);
    end
  else
    m = {};
  end
  dimensions = {info.GeolocationFields(k).Dims.Name};
  for i=1:length(dimensions)
    dimensions{i} = ['DIM:' dimensions{i}];
  end
  geofieldnodes(k) =...
      DataNodeFactory.createSwathFieldNode(info.Filename,...
                                       info.Name,...
                                       info.GeolocationFields(k).Name,...
                                       length(info.GeolocationFields(k).Dims),...
                                       [dimensions m]);
  for j=1:length(info.GeolocationFields(k).Dims)
        diminfo(j) = DimensionInfo(info.GeolocationFields(k).Dims(j).Name,...
                            info.GeolocationFields(k).Dims(j).Size);
%    diminfo = DimensionInfo(info.GeolocationFields(k).Dims(j).Name,...
%                            info.GeolocationFields(k).Dims(j).Size,...
%                            0);
  end
  geofieldnodes(k).setDimensions(diminfo);

  
  if ~isempty(info.MapInfo)
    for i=1:length(info.MapInfo)
      geofieldnodes(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.map'),...
                                    {info.MapInfo(i).Map});
      geofieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.offset')),...
                                    {info.MapInfo(i).Offset});
      geofieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.increment')),...
                                    {info.MapInfo(i).Increment});
    end
  end
  
  if ~isempty(info.IdxMapInfo)
    for i=1:length(info.IdxMapInfo)
      geofieldnodes(k).addStandardAttribute(ImporterResourceBundle.getString('metadata.indexmap'),...
                                    {info.IdxMapInfo(i).Map});
      geofieldnodes(k).addStandardAttribute(pad.concat(ImporterResourceBundle.getString('metadata.indexsize')),...
                                    {info.IdxMapInfo(i).Size});
    end
  end
  
  for i=1:numberOfAttributes
    if isnumeric(info.Attributes(i).Value)
      value = sprintf('%f',double(info.Attributes(i).Value));
    else
      value = {info.Attributes(i).Value};
    end	  
    geofieldnodes(k).addStandardAttribute(info.Attributes(i).Name,...
                                  {value});
  end

  GeolocationFields.add(geofieldnodes(k));
end
Swathnode.add(DataFields);
Swathnode.add(GeolocationFields);

%=====================================================================
%function attributes = createStandardAttributeArray(attributes)
%import com.mathworks.toolbox.matlab.iofun.*;
%attributes = [];
%for i=1:length(attributes)
%  if isnumeric(attributes(i).Value)
%    value = num2str(double(attributes(i).Value(:)'));
%  else
%    value = attributes(i).Value;
%  end	  
%  attributes(i) = StandardAttribute(attributes(i).Name,...
%                            cellstr(value));
%end
%
%======================================================================
function dimensions = createDimensionsArray(dimensionStruct)
import com.mathworks.toolbox.matlab.iofun.*;
for k=1:length(dimensionStruct)
%  attributes = createStandardAttributeArray(dimensionStruct(k).Attributes);
  dimensions(k) = DimensionInfo(dimensionStruct(k).Name,...
                                dimensionStruct(k).Size);

  setNodeAttributes(dimensionStruct(k).Attributes,dimensions(k));
end


%=====================================================================
function setNodeAttributes(attributes,node)
for i=1:length(attributes)
  if isnumeric(attributes(i).Value)
    value = num2str(double(attributes(i).Value(:)'));
  else
    value = attributes(i).Value;
  end	  
  node.addStandardAttribute(attributes(i).Name,...
                    cellstr(value));
end

%======================================================================
%  function s = getProjectionNameFromCode(projCode)
%  codes = [0 1 4 6 7 9 11 20 22 24 99];
%  names = {'Geographic','Universal Transverse Mercator','Lambert Conformal Conic',...
%   'Polar Stereographic','Polyconic','Transverse Mercator',...
%   'Lambert Azimuthal Equal Area','Hotine Oblique Mercator','Space Oblique Mercator',...
%   'Interrupted Goode Homolosine','Integerized Sinusoidal Projection'};
%  
%  i = find(codes==projCode);
%  if ~isempty(i)
%    s = names{i};
%  else
%    s = 'unknown projection';
%  end

%======================================================================
function s = getSphereFromCode(sphereCode)

codes = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19];
names = {'Clarke 1866'
	 'Clarke 1880'
	 'Bessel'
	 'International 1967'
	 'International 1909'
	 'WGS 72'
	 'Everest'
	 'WGS 66'
	 'GRS 1980'
	 'Airy'
	 'Modified Airy'
	 'Modified Everest'
	 'WGS 84'
	 'Southeast Asia'
	 'Austrailian National'
	 'Krassovsky'
	 'Hough'
	 'Mercury 1960'
	 'Modified Mercury 1968'
	 'Spere of Radius 6370997m'};

i = find(codes==sphereCode);
if ~isempty(i)
  s = names{i};
else
  s = 'unknown sphere';
end 
	 
%======================================================================
function setProjectionParams(node,proj,param)
import com.mathworks.toolbox.matlab.iofun.*;
if strcmp(proj,'geo')
end
if strcmp(proj,'utm')   
  node.addStandardAttribute('    Lon/Z',{param(1)});
  node.addStandardAttribute('    Lat/Z',{param(2)});
end
if strcmp(proj,'lamcc') 
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
  if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  node.addStandardAttribute('    First Standard Parallel Lat',{param(3)});
  node.addStandardAttribute('    Second Standard Parallel Lat',{param(4)});
  node.addStandardAttribute('    Central Meridian',{param(5)});
  node.addStandardAttribute('    Projection Origin Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
end
if strcmp(proj,'ps')    
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
    if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  node.addStandardAttribute('    Lon below pole of map',{param(5)});
  node.addStandardAttribute('    True Scale Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
end
if strcmp(proj,'polyc') 
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
    if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  node.addStandardAttribute('    Central Meridian',{param(5)});
  node.addStandardAttribute('    Projection Origin Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
end
if strcmp(proj,'tm')    
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
  if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  node.addStandardAttribute('    Scale Factor',{param(3)});
  node.addStandardAttribute('    Central Meridian',{param(5)});
  node.addStandardAttribute('    Projection Origin Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
end
if strcmp(proj,'lamaz') 
  node.addStandardAttribute('    Sphere Radius',{param(1)});
  node.addStandardAttribute('    Proj. Center Lon',{param(5)});
  node.addStandardAttribute('    Proj. Center Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
end
if strcmp(proj,'hom')   
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
    if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  node.addStandardAttribute('    Scale Factor',{param(3)});
  if param(13)==1 % hom B
    node.addStandardAttribute('    Azimuth angle east of north of center line',{param(4)});
    node.addStandardAttribute('    Long of point on Central Meridian where azimuth occurs',{param(5)});
  end
  node.addStandardAttribute('    Projection Origin Lat',{param(6)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
  if param(13)==0 % hom A
    node.addStandardAttribute('    Long of 1st pt. on center line',{param(9)});
    node.addStandardAttribute('    Lat of 1st pt. on center line',{param(10)});
    node.addStandardAttribute('    Long of 2cd pt. on center line',{param(11)});
    node.addStandardAttribute('    Lat of 2cd pt. on center line',{param(12)});
  end
end
if strcmp(proj,'som')   
  node.addStandardAttribute('    Semi-Major Axis',{param(1)});
  if param(2)>0
    node.addStandardAttribute('    Semi-Minor Axis',{param(2)});
  else
    node.addStandardAttribute('    Ecentricity squared',{-param(2)});
  end
  if param(13)==1 % som B
    node.addStandardAttribute('    Satellite number',{param(3)});
    node.addStandardAttribute('    Landsat path number',{param(4)});
  end
  if param(13)==0 % som A
    node.addStandardAttribute('    Inclination of orbit at ascending node, counter-clockwise from equator',{param(4)});
    node.addStandardAttribute('    Lon of ascending orbit at equator',{param(5)});
  end
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
  if param(13)==0 % som A
    node.addStandardAttribute('    Period of satelite in minutes',{param(9)});
    node.addStandardAttribute('    Satellite ratio to specify start & end pt. of x,y vals on earth surface',{param(10)});
    if param(11)==0
      node.addStandardAttribute('    Path Start/End',{'Start'});
    else
      node.addStandardAttribute('    Path Start/End',{'End'});
    end
  end
end
if strcmp(proj,'good')    
  node.addStandardAttribute('    Sphere Radius',{param(1)});
end
if strcmp(proj,'isinus')  
  node.addStandardAttribute('    Sphere Radius',{param(1)});
  node.addStandardAttribute('    Central Meridian',{param(5)});
  node.addStandardAttribute('    False Easting',{param(7)});
  node.addStandardAttribute('    False Northing',{param(8)});
  node.addStandardAttribute('    Number of latitudinal zones',{param(9)});
  node.addStandardAttribute('    Right justify columns',{param(11)});
end

%======================================================================
%  function n = getNumProjAttrs(proj,param)
%  n = 0;
%  if strcmp(proj,'geo')
%    n = 0;
%  end
%  if strcmp(proj,'utm')   
%    n = 2;
%  end
%  if strcmp(proj,'lamcc') 
%    n = 8;
%  end
%  if strcmp(proj,'ps')    
%    n = 6;
%  end
%  if strcmp(proj,'polyc') 
%    n = 6;
%  end
%  if strcmp(proj,'tm')    
%    n = 7;
%  end
%  if strcmp(proj,'lamaz') 
%    n = 5;
%  end
%  if strcmp(proj,'hom')   
%    if param(13)==1 % hom B
%      n = 8;
%    else
%      n = 10;
%    end
%  end
%  if strcmp(proj,'som')   
%    if param(13)==1 % som B
%      n = 6;
%    end
%    if param(13)==0 % som A
%      n = 9;
%    end
%  end
%  if strcmp(proj,'good')    
%    n = 1; 
%  end
%  if strcmp(proj,'isinus')  
%    n = 6;
%  end

%======================================================================
function match = findVerticalSubsets(info)
% Returns a cell array.  The cell array has as many rows as the number of 
% fields in the Swath or Grid.  The first column is the field name.  The 
% Rest of the columns are other fields that have the following
% characteristics:
%   1.  Field has 1 dimension
%   2.  Field is int16, int32, float, or double
%   3.  A common dimension name
% In addition, to qualify as a possible vertical subset, the field must
% be monotonic, but this function does not check for this.  

match = {};
if ~isempty(info.DataFields)
    datafields_rank1   = info.DataFields(find([info.DataFields.Rank]==1));
else
    datafields_rank1 = [];
end
if isfield(info,'GeolocationFields') && ~isempty(info.GeolocationFields)
    if ~isempty(datafields_rank1)
        data_vrt_fields = datafields_rank1(find(strcmp({datafields_rank1.NumberType},'int16') |...
            strcmp({datafields_rank1.NumberType},'int32') |...
            strcmp({datafields_rank1.NumberType},'float') |...
            strcmp({datafields_rank1.NumberType},'double')));
    else
        data_vrt_fields = [];
    end
    geolocfields_rank1 = info.GeolocationFields(find([info.GeolocationFields.Rank]==1));
    if ~isempty(geolocfields_rank1)
        geo_vrt_fields = geolocfields_rank1(find(strcmp({geolocfields_rank1.NumberType},'int16') |...
            strcmp({geolocfields_rank1.NumberType},'int32') |...
            strcmp({geolocfields_rank1.NumberType},'float') |...
            strcmp({geolocfields_rank1.NumberType},'double')));
    else
        geo_vrt_fields = [];
    end 
    possible_vrt_fields = [data_vrt_fields, geo_vrt_fields];
else
    if ~isempty(datafields_rank1)
        data_vrt_fields = datafields_rank1(find(strcmp({datafields_rank1.NumberType},'int16') |...
            strcmp({datafields_rank1.NumberType},'int32') |...
            strcmp({datafields_rank1.NumberType},'float') |...
            strcmp({datafields_rank1.NumberType},'double')));
    else
        data_vrt_fields = [];
    end
    possible_vrt_fields = data_vrt_fields;
end

for i=1:length(info.DataFields)
  match{i,1} = info.DataFields(i).Name;
  match{i,2} = '';
  
  count=2;
  
  for j=1:length(possible_vrt_fields)
      
    if ((any(strcmp(possible_vrt_fields(j).Dims.Name, ...
                    {info.DataFields(i).Dims.Name}))) && ...
        (~strcmp(possible_vrt_fields(j).Name, ...
                 info.DataFields(i).Name)))
        
        match{i,count} = possible_vrt_fields(j).Name;
        count = count+1;
        
    end
  end
end

if isfield(info,'GeolocationFields')
  for i=1:length(info.GeolocationFields)
    match{i+length(info.DataFields),1} = info.GeolocationFields(i).Name;
    
    count=2;
    
    for j=1:length(possible_vrt_fields)
        
      if ((any(strcmp(possible_vrt_fields(j).Dims.Name, ...
                     {info.GeolocationFields(i).Dims.Name}))) && ...
          (~strcmp(possible_vrt_fields(j).Name, ...
                   info.GeolocationFields(i).Name)))
          
          match{i+length(info.DataFields),count} = possible_vrt_fields(j).Name;
          count = count+1;
          
      end
    end
  end
end
