function h = MapView(varargin)
%MAPVIEW Interactive map viewer   
%   MAPVIEW starts the map viewer in an empty state.  Using the options in
%   the file menu, you can select data from a file or the MATLAB workspace.

%   With no input arguments, MAPVIEW displays a file chooser dialog so you can
%   select a data file interactively.
%
%   MAPVIEW(FILENAME) starts the map viewer and creates a layer from
%   FILENAME. FILENAME can be a name of an image file with a worldfile, a
%   GeoTiff file or an ESRI shapefile. The name of the layer will be the base
%   name of the file.
%
%   MAPVIEW(R,I) starts the map viewer and creates a layer from the referencing
%   matrix R and the RGB image I. The layer will be named "Layer 1".
%
%   MAPVIEW(R,I,CMAP) starts the map viewer and creates a layer from the
%   referencing matrix R, the indexed image I and the colormap CMAP.
%
%   MAPVIEW(VECTORSHAPESTRUCT) starts the map viewer and creates a layer, named
%   "Layer 1", from the vector shape structure VECTORSHAPESTRUCT. See SHAPEREAD
%   for a definition of the vector shape structure.
%
%   MAPVIEW(...,LAYERNAME) names the layer LAYERNAME.
%
%   H = MAPVIEW(...) returns a handle to the Map Viewer.  CLOSE(H) closes the
%   map viewer.

%   MAPVIEW(MapModel) Undocumented way of creating a viewer that views an
%   existing map model.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/03/24 20:41:00 $

h = MapViewer.MapView;
[fromFile,newView,rasterFromWS,...
 shapeFromWS,needFilename,needLayerName,cmap] = parseInputs(varargin{:});

noInputArgs = needFilename;
axesVisibility = 'off';

if needFilename
%  filename = h.getFilename;
%  if isempty(filename)
%    return
%  end
%  mapgate('checkfilename',filename,'mapview',1);
else
  filename = varargin{1};
end

viewerNumber = getViewerNumber(h, newView, varargin);

% If necessary, initialize the Map Model.
if newView
  h.map = varargin{1};
  axesVisibility = 'on';
else
  h.map = MapModel.MapModel(viewerNumber(1));
end

h.map.ViewerCount(viewerNumber(2)) = viewerNumber(2);

% Initialize the figure.
viewerPosition = getViewerPosition;

h.Name = ['Map Viewer ' num2str(viewerNumber(1)) ...
          ': View ' num2str(viewerNumber(2))];

h.Figure = handle(figure('Position',viewerPosition,...
                         'Name',h.Name,getFigureProperties,...
                         'HandleVisibility','off',...
                         'IntegerHandle','off',...
                         'Tag','mapview',...
                         'DeleteFcn',{@figureDelete, h}));

setappdata(h.Figure,'MapModelId',h.map.ModelId);


% Initialize the axis.
h.Axis = h.initializeAxis(h.map,axesVisibility);
h.AnnotationAxes = MapViewer.AnnotationLayer(h.Axis);
h.State = MapViewer.EditState(h);
h.setDefaultState
%%%%%%%%%%%%%%%%%%%%%
h.createMenus;
h.createToolbar;
h.setCursor('wait');
%drawnow
%%%%%%%%%%%%%%%%%%%%%
h.tightFrame;
h.Figure.Visible = 'on';
drawnow;

h.PreviousDataTipState=[];

h.DisplayPane = MapViewer.DisplayPanel(h);

h.Listeners = [handle.listener(h.Axis,h.Axis.findprop('XLim'),...
                               'PropertyPostSet',{@localSetScaleDisplay h h.ScaleDisplay});
               handle.listener(h.Figure,h.Figure.findprop('Position'),...
                               'PropertyPostSet',{@localSetScaleDisplay h h.ScaleDisplay});
               handle.listener(h.Axis,h.Axis.findprop('YLim'),...
                               'PropertyPostSet',{@localSetScaleDisplay h h.ScaleDisplay});
               handle.listener(h.Axis,h.Axis.findprop('YLim'),...
                               'PropertyPreSet',{@saveYLimits h});
               handle.listener(h.Axis,h.Axis.findprop('XLim'),...
                               'PropertyPreSet',{@saveXLimits h});
               handle.listener(findobj(h.Figure,'Type','uimenu','Label','Layers'),...
                               findobj(h.Figure,'Type','uimenu','Label','Layers'),...
                               'ObjectChildAdded',{@resetLayersMenu h});
               handle.listener(h.Figure,h.Figure.findprop('Position'),...
                               'PropertyPostSet',{@figurePositionListener h});...
               handle.listener(h.getMap,'LayerRemoved',{@layerRemoved h});...
               handle.listener(h.getMap,'LayerAdded',{@layerAdded h});...
               handle.listener(h,'ViewChanged',{@storeView});...
              ];


% Add first layer
if fromFile && ~needFilename
  if needLayerName
    [tmppath,tmpname] = fileparts(filename);
    layername = tmpname;
  else
    layername = varargin{2};
  end
  if ~needFilename
    filename = varargin{1};
  end
  h.setCurrentPath(filename);
  try
    h.importFromFile(filename);
  catch
    delete(h.Figure);
    rethrow(lasterror);
  end
elseif rasterFromWS
  if needLayerName
      layername = 'Layer 1';
  else
    if cmap
      layername = varargin{4};
    else
      layername = varargin{3};
    end
  end
  if cmap
    I = ind2rgb8(varargin{2},varargin{3});
  else
    I = varargin{2};
  end
  R = varargin{1};
  h.addLayer(createRGBLayer(R,I,layername));  
elseif shapeFromWS
  if needLayerName
    layername = 'Layer 1';
  else
    layername = varargin{2};
  end
  [shapeData, spec] = updategeostruct(varargin{1});
  % Project the data if needed
  if isfield(shapeData,'Lat') && isfield(shapeData,'Lon')
     %shape = projectGeoStruct(ax, shape);
     [shapeData.X] = deal(shapeData.Lon);
     [shapeData.Y] = deal(shapeData.Lat);
  end
  [layer, tmp] = mapgate('createVectorLayer',shapeData,layername);
  if isstruct(spec)
    layerlegend = layer.legend;
    layerlegend.override(rmfield(spec,'ShapeType'));
  end
  h.addLayer(layer);
elseif newView
  layerorder = h.map.getLayerOrder;
  for i=length(h.map.Layers):-1:1
    h.addLayerMenu(h.map.getLayer(layerorder{i}));
  end
  layername = 'None';
else
  layername = 'None';
end

%Disabled for noInputArgs
%h.setActiveLayer(layername);

% Set the axis limits (only for the first layer)
if noInputArgs
  h.Axis.refitAxisLimits;
  setNoLayerState(h,'startup');
elseif newView
  setNoLayerState(h);
else
  h.fitToWindow;
end

h.Axis.updateOriginalAxis;
localSetScaleDisplay([],[],h,h.ScaleDisplay);
h.setCursor('arrow');

h.LastLimits(:,1) = h.Axis.XLim(:);
h.LastLimits(:,2) = h.Axis.YLim(:);

setSessionPreferences(h);

function layerAdded(hSrc,event,this)
layername = event.LayerName;
layer = this.getMap.getLayer(layername);
this.addLayerMenu(layer);
hDisplayPane = handle(this.DisplayPane);
hDisplayPane.addLayer(layer);
setNoLayerState(this);
changeZoomResetView(this);

function layerRemoved(hSrc,event,this)
layerName = event.LayerName;
this.DisplayPane.removeLayer(layerName);

activeLayerName = this.getActiveLayerName;
if strcmp(class(this.State),'MapViewer.DataTipState')
    this.State.removeLayer(layerName);
elseif ~isempty(this.PreviousDataTipState)
    this.PreviousDataTipState.removeLayer(layerName);
end
if strcmp(class(this.State),'MapViewer.InfoToolState')
    this.State.removeLayer(layerName);
elseif ~isempty(this.PreviousInfoToolState)
    this.PreviousInfoToolState.removeLayer(layerName);
end

if (length(this.Map.getLayerOrder) == 0)
  setNoLayerState(this);
end
layersMenu = findall(this.Figure,'Tag','layers');
menuItem = findall(layersMenu,'Label',layerName);
delete(menuItem);
changeZoomResetView(this);

function figurePositionListener(hSrc,event,this, doResizeLimits)
defaultAxisSize(this);
resizeLimits(this);

function defaultAxisSize(this)
fig = this.Figure;
ax  = this.Axis;
oldunits = get(fig,'Units');
set(fig,'Units','pixels');
p = get(fig,'Position');
set(fig,'Units',oldunits);

leftMargin = 10 + this.ExtraLeftMargin;
bottomMargin = 65 + this.ExtraBottomMargin;
topMargin = 10 + this.ExtraTopMargin;
rightMargin = 10;
axisPosition = [leftMargin,bottomMargin,p(3) - leftMargin - rightMargin,p(4) ...
                - bottomMargin - topMargin];
oldunits = get(ax,'Units');
set(ax,'Units','pixels');
set(ax,'Position',axisPosition);
set(ax,'Units',oldunits);

function resizeLimits(this)
oldunits = this.Axis.Units;
this.Axis.Units = 'pixels';
  
% Resize the axis limits to negate any rescaling
xChngFactor = this.Axis.Position(3) / this.Axis.OrigPosition(3);
yChngFactor = this.Axis.Position(4) / this.Axis.OrigPosition(4);
xlim = sum(this.Axis.OrigXLim)/2 + [-1/2, 1/2] * diff(this.Axis.OrigXLim) * xChngFactor;
ylim = sum(this.Axis.OrigYLim)/2 + [-1/2, 1/2] * diff(this.Axis.OrigYLim) * yChngFactor;

this.Axis.Units = oldunits;
if diff(xlim) > 0
  this.Axis.XLim = xlim;
end
if diff(ylim) > 0
  this.Axis.YLim = ylim;
end

function resetLayersMenu(hSrc,event,this)
m = findobj(this.Figure,'Type','uimenu','Label','Layers');
set(m,'Children',get(m,'Children'));

function saveXLimits(hSrc,event,this)
this.LastLimits(:,1) = this.Axis.XLim(:);

function saveYLimits(hSrc,event,this)
this.LastLimits(:,2) = this.Axis.YLim(:);

function localSetScaleDisplay(hSrc,event,h,scale)
if (~isempty(event))
  srcName = event.Source.Name;
else
  srcName = '';
end
fixZoomView(h, srcName);
if isempty(h.Axis.getScale)
  set(scale,'String','Units Not Set');
else
  s = ['1:' num2str(floor(1/h.Axis.getScale))];
  set(scale,'String',s)
end 

function viewerPosition = getViewerPosition
% Much of this is stolen from fdatool. Maybe it should be a function in
% toolbox/matlab/uitools?

% Figure out screen resolution.
oldRootUnits = get(0,'Units');
set(0, 'Units', 'pixels');

% Determine a scale factor based on screen resolution.
pf = get(0,'screenpixelsperinch')/96;

viewerPosition = get(0,'DefaultFigurePosition');
viewerPosition(3:4) = [800 400]*1.5;
viewerPosition = viewerPosition * pf;

% Make sure it didn't land right on top of another Map Viewer
viewerPosition = cascadeViewers(viewerPosition);

% Make sure the title bar of the window isn't off the screen

rootScreenSize = get(0,'ScreenSize');

% (position is [x(from left) y(bottom edge from bottom) width height]
% check left edge and right edge
if ((viewerPosition(1) < 1) ...
      || (viewerPosition(1) + viewerPosition(3) > rootScreenSize(3)))
   viewerPosition(1) = 30;
end

% Make sure top of figure is not off the screen.
if ((viewerPosition(2) < 1) ...
      || (viewerPosition(2) + viewerPosition(4) > rootScreenSize(4)))
  viewerPosition(2) = viewerPosition(2) - ...
      ((viewerPosition(2) + viewerPosition(4) + 100)-rootScreenSize(4));
end

set(0, 'Units', oldRootUnits);

function props = getFigureProperties
props.Visible = 'off'; 
props.NumberTitle = 'off';
props.DoubleBuffer = 'on';
if ispc
  props.Renderer     = 'zbuffer';
  props.RendererMode = 'manual';
else
  props.Renderer     = 'painters';
end
if ~isempty(findstr(version,'R14'))
  props.Toolbar = 'None';
else
  props.Toolbar = 'Figure';
end

function newLayer = createRGBLayer(R,I,name)
newLayer = MapModel.RasterLayer(name);
newComponent = MapModel.RGBComponent(R,I,struct([]));
newLayer.addComponent(newComponent);

function attrStruct = getShapeAttributeStruct(shapeData)
attrStruct = mapgate('geoattribstruct',shapeData);

function [fromFile,newView,rasterFromWS,shapeFromWS,needFilename,needLayerName,cmap] = parseInputs(varargin)
% Variable Initialization
fromFile = false;
newView = false;
rasterFromWS = false;
shapeFromWS = false;
cmap = false;
needFilename = false;
needLayerName = false;

if (nargin == 0) % H = MAPVIEW
  needFilename = true;
  fromFile = true;
  needLayerName = true;
elseif  (nargin == 1) && ischar(varargin{1}) % MAPVIEW(FILENAME)
  mapgate('checkfilename',varargin{1},'mapview',1);
  fromFile = true;
  needLayerName = true;
elseif (nargin == 1) && strcmp(class(varargin{1}),'MapModel.MapModel') % MAPVIEW(MAP)
  newView = true;
elseif (nargin == 1) && isstruct(varargin{1}) % MAPVIEW(VECTORDATA)
  shapeFromWS = true;
  needLayerName = true;  
elseif (nargin == 2) && (ischar(varargin{1}) && ischar(varargin{2})) % MAPVIEW(FILENAME,LAYERNAME)
  mapgate('checkfilename',varargin{1},'mapview',1);
  fromFile = true;
elseif (nargin == 2) && (isnumeric(varargin{1}) && isnumeric(varargin{2})) % MAPVIEW(R,I)
  mapgate('checkinput',varargin{1},'numeric',{'real' 'nonempty' 'finite'},...
        'mapview','R',1);
  mapgate('checkinput',varargin{2},'numeric',{'real' 'nonempty' 'finite'},...
        'mapview','I',2);
  rasterFromWS = true;
  needLayerName = true;
elseif (nargin == 3) && (isnumeric(varargin{1}) && ...
                         isnumeric(varargin{2}) && isnumeric(varargin{3})) % MAPVIEW(R,I,CMAP)
  mapgate('checkinput',varargin{1},'numeric',{'real' 'nonempty' 'finite'},...
             'mapview','R',1);
  mapgate('checkinput',varargin{2},'numeric',{'real' 'nonempty' 'finite'},...
             'mapview','I',2);
  mapgate('checkinput',varargin{2},'numeric',{'real' 'nonempty' 'finite'},...
             'mapview','CMAP',2);
  rasterFromWS = true;
  needLayerName = true;
  cmap = true;
elseif (nargin == 2) && (isstruct(varargin{1}) && ischar(varargin{2})) % MAPVIEW(VECTORDATA,LAYERNAME)
  shapeFromWS = true;
elseif (nargin == 3) && (isnumeric(varargin{1}) && isnumeric(varargin{2})) % MAPVIEW(R,I,LAYERNAME)
  mapgate('checkinput',varargin{1},'numeric',{'real' 'nonempty' 'finite'},...
        'mapview','R',1);
  mapgate('checkinput',varargin{2},'numeric',{'real' 'nonempty' 'finite'},...
        'mapview','I',2);
  rasterFromWS = true;
elseif (nargin == 4) &&...
      (isnumeric(varargin{1}) && isnumeric(varargin{2}) ...
        && isnumeric(varargin{3}) && ischar(varargin{4})) % MAPVIEW(R,I,CMAP,LAYERNAME)
  mapgate('checkinput',varargin{1},'numeric',{'real' 'nonempty' 'finite'},...
        'mapview','R',1);
  mapgate('checkinput',varargin{2},'numeric',{'real' 'nonempty' 'finite'},...
             'mapview','I',2);
  mapgate('checkinput',varargin{3},'numeric',{'real' 'nonempty' 'finite'},...
             'mapview','CMAP',3);
  rasterFromWS = true;
  cmap = true;
else
  error('Invalid inputs for MAPVIEW.');
end

function p = cascadeViewers(viewerPosition)
p = viewerPosition;
viewers = findall(0,'Tag','mapview');
for i=1:length(viewers)
  oldunits = get(viewers(i),'Units');
  set(viewers(i),'Units','Pixels');
  viewerPos = get(viewers(i),'Position');
  set(viewers(i),'Units',oldunits);
  if isequal(viewerPos(1),viewerPosition(1)) &&...
        isequal(viewerPos(2),viewerPosition(2))
    p(1) = viewerPosition(1) - 50;
    p(2) = viewerPosition(2) - 50;
    p = cascadeViewers(p);
  end
end

function setSessionPreferences(this)
this.Preferences.ShowDatatipUsage = true;

function viewerNumber= getViewerNumber(h, newView, varargin)
% Returns the MapModel Id and the MapViewer number

currentMapViews = findall(0,'Tag','mapview');

if isempty(currentMapViews)
  newModelId = 1;
  newViewNumber = 1;
else
  for n = 1:length(currentMapViews)
    % extract the Model Ids from the figure's appdata.
    mapModelIds(n) = getappdata(currentMapViews(n),'MapModelId');
  end
  
  if newView
    newMap = varargin{1}{1};
    newModelId = newMap.ModelId;
    
    %Get the lowest unused viewer number.
    newViewNumber = find(~newMap.ViewerCount);
    if isempty(newViewNumber)
      newViewNumber = length(~newMap.ViewerCount) + 1;
    else
      newViewNumber = newViewNumber(1);
    end      
  else
      % determine any unused Model Ids
    newModelId = setxor(1:max(mapModelIds), mapModelIds);
    if isempty( newModelId )
      newModelId = max(mapModelIds)+1;
    end
    newViewNumber = 1;
  end
end

viewerNumber = [newModelId, newViewNumber];


function figureDelete(fig, event, this)
ind = strfind(this.Name,'w');
num = str2num(this.Name(ind(end)+1:end));
this.Map.ViewerCount(num) = 0;
if strcmp(class(this.State),'MapViewer.InfoToolState')
    this.State.closeAll;
elseif ~isempty(this.PreviousInfoToolState)
    this.PreviousInfoToolState.closeAll;
end




function changeZoomResetView(this)
KEY = 'matlab_graphics_resetplotview';
hZoom = getappdata(this.Figure,'ZoomObject');
viewInfo = getappdata(this.Axis,KEY);

layerOrder = this.map.getLayerOrder;
if (isempty(viewInfo)) || ...  % Zoom hasn't been enabled yet.
      isempty(layerOrder) % There are no layers in the MapViewer      
  return
end

scribefiglisten(this.Figure,'off');
tmpAxes = MapGraphics.axes('Parent',this.Axis.Parent,...
                           'Visible','off',...
                           'Position',this.Axis.Position);
topLayer = this.map.getLayer(layerOrder{1});
tmpAxes.setAxesLimits(this.map.getBoundingBox.getBoxCorners);
tmpAxes.refitAxisLimits; 

viewInfo.XLim = tmpAxes.XLim;
viewInfo.YLim = tmpAxes.YLim;

delete(tmpAxes)
setappdata(this.Axis,KEY,viewInfo);
scribefiglisten(this.Figure,'on');


function fixZoomView(h, srcName)
st = class(h.State);
isZoomState = strncmp('zoom',lower(st(strfind(st,'.')+1:end)),4);
if (~isZoomState || ~strcmp(srcName,'YLim'))
  return
end

defaultAxisSize(h);

h.Axis.refitAxisLimits;
h.Axis.updateOriginalAxis;
vEvent = MapViewer.ViewChanged(h);
h.send('ViewChanged',vEvent);

if ~isempty(h.UtilityAxes)
  set(double(h.UtilityAxes),'XLim',h.Axis.XLim,...
                    'YLim',h.Axis.YLim);
end

function storeView(hSrc,event)
if hSrc.ViewIndex >= 0
  hSrc.ViewIndex = hSrc.ViewIndex + 1;
  hSrc.PreviousViews(hSrc.ViewIndex:end,:) = [];
  hSrc.PreviousViews(hSrc.ViewIndex,1:2) = hSrc.Axis.XLim;
  hSrc.PreviousViews(hSrc.ViewIndex,3:4) = hSrc.Axis.YLim;
end

if size(hSrc.PreviousViews,1)== 2
  viewMenu = findobj(hSrc.Figure,'type','uimenu','Label','View');
  toolbar = findall(hSrc.Figure,'type','uitoolbar');
  backMenuItem = findall(viewMenu,'Label','Previous View');
  backTool = findall(toolbar,'tag','back to previous view');
  set([backTool,backMenuItem],'Enable','on');
end
%toolbar = findall(this.Figure,'type','uitoolbar');
%backTool = findall(toolbar,'Tooltip','back to previous view');
%set(backTool,'Enable','on');


function setNoLayerState(this,state)
% Sets the viewer to the no Layer states:
%   startup: when the viewer starts up without any arguments.
% The layername argument enables setting the first layer
% added to the viewer as the active layer.

toolbar = findall(this.Figure,'type','uitoolbar');
toolbarCh = get(toolbar,'Children');
printTool = findall(toolbar,'Tooltip','Print figure');

fileMenu = findobj(this.Figure,'type','uimenu','Label','File');
fmenuOptions = get(fileMenu,'Children');

viewMenu = findobj(this.Figure,'type','uimenu','Label','View');
vmenuOptions = get(viewMenu,'Children');

insertMenu = findobj(this.Figure,'type','uimenu','Label','Insert');
imenuOptions = get(insertMenu,'Children');

toolsMenu = findobj(this.Figure,'type','uimenu','Label','Tools');
tmenuOptions = get(toolsMenu,'Children');

% make sure the right menu options are checked
if nargin > 1 && strcmp(state,'startup')
  set([toolbarCh;vmenuOptions;imenuOptions;tmenuOptions],'Enable','off');
  set(fmenuOptions([2,3,4]),'Enable','off');
  set(printTool,'Enable','off');
  set(this.Figure,'WindowButtonMotionFcn','');
  set(this.DisplayPane.MapUnitsDisplay,'String','None');
else
  st = class(get(this,'state'));
  if isequal(st,'MapViewer.DefaultState') || isequal(st,'MapViewer.EditState')
     set(findobj(toolbarCh,'type','uitoggletool'),'State','off');
     this.setDefaultState;
  end
  if (length(this.Map.getLayerOrder) == 0)
    this.ViewIndex = 0;
    this.PreviousViews = [];
    toolbar = findall(this.Figure,'type','uitoolbar');
    viewMenu = findobj(this.Figure,'type','uimenu','Label','View');
    backTool = findall(toolbar,'tag','back to previous view');
    backMenuItem = findall(viewMenu,'Label','Previous View');
    set([backTool,backMenuItem,toolbarCh(1)],'Enable','off');
    set(vmenuOptions([4:5]),'Enable','off');
    this.setActiveLayer('None');
  elseif (length(this.Map.getLayerOrder) == 1)
    if strcmp(this.Axis.Visible,'off') %first layer is being added
      this.Axis.Visible = 'on';
      set(this.DisplayPane.MapUnitsDisplay,...
          'String',{this.DisplayPane.MapUnits{:,1}});
      % When the first layer is added we want to exclude the previous view, 
      % info and data tip toolbar buttons and menu items
      tbarInd = setxor(1:length(toolbarCh),[2:4]);
      tmenuInd = setxor(1:length(tmenuOptions),[8:9]);
      
      set([toolbarCh(tbarInd);...
           vmenuOptions([1:end]~=3);...
           imenuOptions;...
           tmenuOptions(tmenuInd);...
           fmenuOptions([2,3,4])],...
          'Enable','on');
      set(printTool,'Enable','on');
      this.setActiveLayer(this.Map.getLayerOrder{1});
    end
    this.setActiveLayer(this.getActiveLayerName);
    this.ViewIndex = -1;
    this.fitToWindow;
    this.PreviousViews = [];
    this.ViewIndex = 0;
    vEvent = MapViewer.ViewChanged(this);
    this.send('ViewChanged',vEvent);
    set(toolbarCh(1),'Enable','on');
    set(vmenuOptions([4:5]),'Enable','on');    
  end
end
