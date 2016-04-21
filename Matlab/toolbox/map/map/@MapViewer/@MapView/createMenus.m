function createMenus(this)
%CREATEMENUS Create menus for MapView

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:54 $

% Delete current menus and create new menus
delete(findall(this.Figure, 'Type','uimenu', 'Parent',this.Figure));

% File 
fileMenu = uimenu('Parent',this.Figure,'Label','File','Tag','file');

% Import
uimenu('Parent',fileMenu,'Label','Import From File...',...
       'Tag','fileimport','Callback',{@localImportFromFile this});
importFromWorkspace = uimenu('Parent',fileMenu,'Label',['Import From ' ...
                    'Workspace']);

RasterImport = uimenu('Parent',importFromWorkspace,'Label','Raster Data');
uimenu('Parent',RasterImport,'Label','Image...',...
       'Callback',{@localImportRasterFromWS this,'image'});       
uimenu('Parent',RasterImport,'Label','Grid...',...
       'Callback',{@localImportRasterFromWS this,'grid'});

VectorImport = uimenu('Parent',importFromWorkspace,'Label','Vector Data');
uimenu('Parent',VectorImport,'Label','Map Coordinates...',...
       'Callback',{@localImportVectorFromWS this 'cartesian'});
uimenu('Parent',VectorImport,'Label','Geographic Data Structure...',...
       'Callback',{@localImportVectorFromWS this 'struct'});

% New View
newview = uimenu('Parent',fileMenu,'Label','New View');
uimenu('Parent',newview,'Label','Duplicate Current View',...
       'Callback',{@localNewViewVisible this});
uimenu('Parent',newview,'Label','Full Extent',...
       'Callback',{@localNewViewFull this});
uimenu('Parent',newview,'Label','Full Extent Of Active Layer',...
       'Callback',{@localNewViewActiveLayer this});
this.NewViewAreaMenu = handle(uimenu('Parent',newview,'Label','Selected Area',...
                                     'Callback',{@localNewViewArea this}, ...
                                     'Enable','off'));

% Save Raster Map
SaveAs = uimenu('Parent',fileMenu,'Label','Save As Raster Map');
uimenu('Parent',SaveAs,'Label','Visible Area',...
       'Tag','exportvisiblearea','Callback',{@localExportVisibleArea this}); 
this.ExportAreaMenu = handle(uimenu('Parent',SaveAs,'Label','Selected Area',...
       'Tag','exportselectedarea','Callback',{@localExportArea this},...
       'Enable','off'));

% Print
uimenu('Parent',fileMenu,'Label','Print...',...
       'Callback',{@localPrint,this});

% Close
uimenu('Parent',fileMenu,'Label','Close',...
       'Callback',{@localClose this});

% Edit 
this.EditMenu = uimenu('Parent',this.Figure,'Label','Edit');
uimenu('Parent',this.EditMenu,'Label','Cut','Enable','off',...
       'Tag','cut','Callback',{@localCut this});
uimenu('Parent',this.EditMenu,'Label','Copy','Enable','off',...
       'Tag','copy','Callback',{@localCopy this});
uimenu('Parent',this.EditMenu,'Label','Paste','Enable','off',...
       'Tag','paste','Callback',{@localPaste this});
uimenu('Parent',this.EditMenu,'Label','Select All','Enable','off',...
       'Tag','select all','Separator','on','Callback',{@localSelectAll this});
   
listeners = [handle.listener(this.AnnotationAxes,'ObjectChildAdded',...
                             {@annotationsChanged, this});...
             handle.listener(this.AnnotationAxes,'ObjectChildRemoved',...
                             {@annotationsChanged, this})];

setappdata(this.EditMenu,'AnnotationListeners',listeners);
       

% View 
viewMenu = uimenu('Parent',this.Figure,'Label','View');
uimenu('Parent',viewMenu,'Label','Tight Frame',...
       'Callback',{@doTightFrame this});
uimenu('Parent',viewMenu,'Label','Fit To Window',...
       'Callback',{@doFitToWindow this});
uimenu('Parent',viewMenu,'Label','Previous View',...
       'Callback',{@doBackToPreviousView this});
uimenu('Parent',viewMenu,'Label','Toolbar',...
       'Checked','on','Callback',{@localToolbar this});
uimenu('Parent',viewMenu,'Label','Show Annotations',...
       'Separator','on','Checked','on',...
       'Callback',{@localShowAnnotations this});
%gridLines = uimenu('Parent',viewMenu,'Label','Show Gridlines',...
%                   'Checked','off','Callback',grid);

% Insert 
insertMenu = uimenu('Parent',this.Figure,'Label','Insert');
uimenu('Parent',insertMenu,'Label','Arrow',...
       'Callback',{@doMenuItemViaToggleTool, this, 'insert arrow'});
uimenu('Parent',insertMenu,'Label','Line',...
       'Callback',{@doMenuItemViaToggleTool, this, 'insert line'});
uimenu('Parent',insertMenu,'Label','Text',...
       'Callback',{@doMenuItemViaToggleTool, this, 'insert text'});
uimenu('Parent',insertMenu,'Label','Xlabel',...
       'Separator','on',...
       'Callback',{@localXLabel this});
uimenu('Parent',insertMenu,'Label','Ylabel',...
       'Callback',{@localYLabel this});
uimenu('Parent',insertMenu,'Label','Title',...
       'Callback',{@localTitle this});

% Tools 
toolsMenu = uimenu('Parent',this.Figure,'Label','Tools');
uimenu('Parent',toolsMenu,'Label','Select Annotations',...
       'Checked','on','Tag','select annotations menu',...
       'Callback',{@doMenuItemViaToggleTool,this,'select annotations'});
dataTipMenu = uimenu('Parent',toolsMenu,'Label','Datatip','Tag','datatip tool menu',...
                     'Callback',{@doMenuItemViaToggleTool,this,['datatip ' ...
                    'tool']});
uimenu('Parent',toolsMenu,'Label','Info Tool','Tag','info tool menu',...
       'Callback',{@doMenuItemViaToggleTool,this,'info tool'});
uimenu('Parent',toolsMenu,'Label','Select Area','Tag','select area menu',...
       'Callback',{@doMenuItemViaToggleTool,this,'select area'});
mapUnits = uimenu('Parent',toolsMenu,'Label','Set Map Units');
uimenu('Parent',toolsMenu,'Label','Zoom In','Separator','on',...
       'Tag','zoom in menu',...
       'Callback',{@doMenuItemViaToggleTool, this,'zoom in'});
uimenu('Parent',toolsMenu,'Label','Zoom Out',...
       'Tag','zoom out menu',...
       'Callback',{@doMenuItemViaToggleTool,this,'zoom out'});
uimenu('Parent',toolsMenu,'Label','Pan',...
       'Tag','pan tool menu',...
       'Callback',{@doMenuItemViaToggleTool,this,'pan tool'});

uimenu('Parent',toolsMenu,'Label','Delete All Datatips','Tag','delete all datatip',...
       'Separator','on','Callback',{@deleteAllDataTips this});
uimenu('Parent',toolsMenu,'Label','Close All Info Windows','Tag','close all infobox',...
       'Callback',{@closeAllInfoBox this});

% Set Map Units 
uimenu('Parent',mapUnits,'Label','None','Tag','none','Checked','on',...
       'Callback',{@localSetMapUnits this});
uimenu('Parent',mapUnits,'Label','Kilometers','Tag','km','Checked','off',...
       'Callback',{@localSetMapUnits this});
uimenu('Parent',mapUnits,'Label','Meters','Tag','m','Checked','off',...
       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','Centimeters','Tag','cm','Checked','off',...
%       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','Millimeters','Tag','mm','Checked','off',...
%       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','Microns','Tag','u','Checked','off',...
%       'Callback',{@localSetMapUnits this});
uimenu('Parent',mapUnits,'Label','Nautical Miles','Tag','nm','Checked','off',...
       'Callback',{@localSetMapUnits this});
uimenu('Parent',mapUnits,'Label','International Feet','Tag','ft','Checked','off',...
       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','Inches','Tag','in','Checked','off',...
%       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','Yards','Tag','yd','Checked','off',...
%       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','International Mile','Tag','mi','Checked','off',...
%       'Callback',{@localSetMapUnits this});
uimenu('Parent',mapUnits,'Label','U.S. Survey Feet','Tag','sf','Checked','off',...
       'Callback',{@localSetMapUnits this});
%uimenu('Parent',mapUnits,'Label','U.S. Survey Miles','Tag','sm','Checked','off',...
%       'Callback',{@localSetMapUnits this});

% Layers menu
layersMenu = uimenu('Parent',this.Figure,'Label','Layers','Tag','layers');

% Help menu
helpMenu = uimenu('Parent',this.Figure,'Label','Help');
uimenu('Parent',helpMenu,'Label','Map Viewer Help','tag','mapviewhelpref',...
       'Callback',{@localShowHelp});

%---------- Callbacks ----------%
function doTightFrame(hSrc,event,this)
this.tightFrame;

function localExportVisibleArea(hSrc,event,this)
im = getframe(this.Axis);
[filename pathname] = uiputfile({'*.tif','TIFF (*.tif,*.tiff,*.TIF,*.TIFF)';...
                                 '*.jpg','JPEG (*.jpg)';...
                                 '*.png','PNG (*.png)'},'Export To File');
if isequal(filename,0) | isequal(pathname,0)
  % User hit cancel.  Do nothing.
else
  [p,name,ext] = fileparts(filename);
  if isempty(ext)
    ext = '.tif';
  end
  filename = fullfile(pathname,[name ext]);
  if ~isempty(im.colormap)
    imwrite(im.cdata,im.colormap,filename,ext(2:end));
  else
    imwrite(im.cdata,filename,ext(2:end));
  end
end

function localExportArea(hSrc,event,this)
rect = [this.FigureSelectionBox(1,:) diff(this.FigureSelectionBox)];
vState = this.State.Box.Visible;
this.State.Box.Visible = 'off';
im = getframe(this.Figure,rect);
this.State.Box.Visible = vState;
[filename pathname] = uiputfile({'*.tif','TIFF (*.tif,*.tiff,*.TIF,*.TIFF)';...
                                 '*.jpg','JPEG (*.jpg)';...
                                 '*.png','PNG (*.png)'},'Export To File');
if isequal(filename,0) | isequal(pathname,0)
    % User hit cancel.  Do nothing.
else
  [p,name,ext] = fileparts(filename);
  if isempty(ext)
    ext = '.tif';
  end
  filename = fullfile(pathname,[name ext]);
  if ~isempty(im.colormap)
    imwrite(im.cdata,im.colormap,filename,ext(2:end));
  else
    imwrite(im.cdata,filename,ext(2:end));
  end
end

function localPan(hSrc,event,this)
toolbar = findall(this.Figure,'type','uitoolbar');
panToggleTool = findobj(get(toolbar,'Children'),'Tag','pan tool');
toolGroup(panToggleTool);
set(panToggleTool,'State','on');
 
function localSetMapUnits(hSrc,event,this)
mapUnitsDropMenu = this.DisplayPane.MapUnitsDisplay;
mapUnitsTag = get(hSrc,'Tag');
mapUnitsInd = strmatch(mapUnitsTag,this.DisplayPane.MapUnits(:,2),'exact');
mapUnitsStr = this.DisplayPane.MapUnits{mapUnitsInd,1};
mapParent = get(hSrc,'Parent');
set(get(mapParent,'Children'),'Checked','off');
set(hSrc,'Checked','on');

set(mapUnitsDropMenu,'Value',mapUnitsInd);
this.DisplayPane.setMapUnits(this,mapUnitsTag);

function localImportFromFile(hSrc,event,viewer)
filename = viewer.getFilename;
if ~isempty(filename)
  try
    viewer.importFromFile(filename);
  catch
    errordlg(lasterr,'Import Error','model');
    viewer.setCursor('restore');
  end
end

function localImportRasterFromWS(hSrc,event,viewer,type)
MapViewer.RasterImport(viewer,type);

function localImportVectorFromWS(hSrc,event,viewer,type)
MapViewer.VectorImport(viewer,type);

function localClose(hSrc,event,viewer)
delete(viewer.Figure);

function localToolbar(hSrc,event,viewer)
menu = gcbo;
switch get(menu,'Checked')
 case 'on'
  set(menu,'Checked','off');
  toolbar = findall(viewer.Figure,'type','uitoolbar');
  set(toolbar,'Visible','off');
 case 'off'
  set(menu,'Checked','on');
  toolbar = findall(viewer.Figure,'type','uitoolbar');
  set(toolbar,'Visible','on');
end

function doMenuItemViaToggleTool(hSrc,event,viewer,tag)
% Execute the menu item by "pushing" the appropriate toggle tool button.
toolbar = findall(viewer.Figure,'type','uitoolbar');
toggleTool = findobj(get(toolbar,'Children'),'Tag',tag);
if strcmp(get(toggleTool,'State'),'off')
  set(toggleTool,'State','on');
else
  set(toggleTool,'State','off');
end
toolGroup(toggleTool);

% Edit Menu
function localCopy(hSrc,event,viewer)
% Will not work if more than one object is selected - however, at this time,
% only one selected object is allowed.
selectedAnnot = findall(double(viewer.AnnotationAxes),'Selected','on');
viewer.CopiedObject = makeCopy(handle(selectedAnnot));
pasteMenu = findall(viewer.EditMenu,'Label','Paste');
set(pasteMenu,'Enable','on');

function localPaste(hSrc,event,viewer)
p = viewer.getMapCurrentPoint;
if ~isempty(viewer.CopiedObject)
  newObject = viewer.CopiedObject.makeCopy;
  newObject.paste(p);
  newObject.setEditMode(true);
end

function localSelectAll(hSrc,event,viewer)
% Select all objects in AnnotationAxes
annotations = get(double(viewer.AnnotationAxes),'Children');
set(annotations,'Selected','on');

% Enable/Disable Edit menu items - Disable copy/paste menus?
cutMenu = findall(viewer.EditMenu,'Label','Cut');
set(cutMenu,'Enable','on');
if length(annotations) > 1
  copyMenu = findall(viewer.EditMenu,'Label','Copy');
  set(copyMenu,'Enable','off');
end

function localCut(hSrc,event,viewer)
delete(findall(double(viewer.AnnotationAxes),'Selected','on'));
set(gcbo,'Enable','off');
copyMenu = findall(viewer.EditMenu,'Label','Copy');
set(copyMenu,'Enable','off');
set(viewer.Figure,'WindowButtonMotionFcn','');
set(viewer.Figure,'WindowButtonUpFcn','');

function localShowAnnotations(hSrc,event,viewer)
annotations = viewer.AnnotationAxes.Children;

menu = gcbo;
switch get(menu,'Checked')
 case 'on'
  set(menu,'Checked','off');
  set(annotations,'Visible','off');
 case 'off'
  set(menu,'Checked','on');
  set(annotations,'Visible','on');
end

function localYLabel(hSrc,event,viewer)
viewer.addYLabel;

function localXLabel(hSrc,event,viewer)
viewer.addXLabel;

function localTitle(hSrc,event,viewer)
viewer.addTitle;

function localNewViewFull(hSrc,event,this)
this.setCursor('wait');
newview = MapViewer.MapView(this.Map);
newview.setActiveLayer(this.getActiveLayerName);
newview.fitToWindow;
this.setCursor('restore');

function localNewViewActiveLayer(hSrc,event,this)
activeLayer = this.getMap.getLayer(this.getActiveLayerName);
if isempty(activeLayer)
  warndlg('You must make a layer active.','No Active Layer','modal');
else
  this.setCursor('wait');
  newview = MapViewer.MapView(this.map);
  newview.setMapLimits(activeLayer.getBoundingBox.getBoxCorners);
  newview.setActiveLayer(this.getActiveLayerName);
  newview.Axis.refitAxisLimits;
  newview.Axis.updateOriginalAxis;
  this.setCursor('restore');
end

function localNewViewVisible(hSrc,event,this)
this.setCursor('wait');
newview = MapViewer.MapView(this.Map);
newview.setMapLimits(this.getMapLimits);
newview.setActiveLayer(this.getActiveLayerName);
newview.Axis.refitAxisLimits;
newview.Axis.updateOriginalAxis;
this.setCursor('restore');

function localNewViewArea(hSrc,event,this)
this.setCursor('wait');
newview = MapViewer.MapView(this.Map);
newview.setMapLimits(this.SelectionBox);
newview.setActiveLayer(this.getActiveLayerName);
newview.Axis.refitAxisLimits;
newview.Axis.updateOriginalAxis;
this.setCursor('restore');

function localPrint(hSrc,event,this)
this.printMap;


function toolGroup(tool)
hiddenHandles = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
tools = findall(get(get(tool,'Parent'),'Parent'),'type','uitoggletool');
set(0,'ShowHiddenHandles',hiddenHandles);
set(tools(tools ~= tool),'State','off');

function doFitToWindow(hSrc,event,viewer)
mapgate('doFitToWindow', hSrc, event, viewer);

function doBackToPreviousView(hSrc,event,viewer)
viewCount = size(viewer.PreviousViews,1);
ind = viewer.ViewIndex;
ind = mod(ind-1,viewCount+1);
if ind < 1, ind = viewCount;end
lastLims = [viewer.PreviousViews(ind,1:2);...
            viewer.PreviousViews(ind,3:4)]';
viewer.setMapLimits(lastLims);
viewer.ViewIndex = ind;

function annotationsChanged(hSrc, event, this)
menus = [findall(this.EditMenu,'Tag','select all');
         findall(this.EditMenu,'Tag','cut');
         findall(this.EditMenu,'Tag','copy')];

annotations = get(this.AnnotationAxes,'Children');

if (strcmp(get(event,'Type'),'ObjectChildAdded'))
  if isa(event.Child,'MapGraphics.DragLine')
    listener  = handle.listener(event.Child,'LineFinished',...
                               {@lineAdded, this});
    setappdata(event.Child,'lineListener',listener); 
  elseif isa(event.Child,'MapGraphics.ArrowHead')
    % Left empty since the ArrowHead and actual line are added separately.
  else% This is for the Text and non-Line Annotations
    toolbar = findall(this.Figure,'type','uitoolbar');
    allToggleTools = findall(get(toolbar,'Children'),'Type','uitoggletool');
    selAnnotTool = findobj(allToggleTools,'Tag','select annotations');
    set(allToggleTools,'State','off');
    set(selAnnotTool,'State','on');
    set(menus(1),'enable','on');
  end
elseif (strcmp(get(event,'Type'), 'ObjectChildRemoved'))
  set(menus(2:3), 'enable','off');
  % the ObjectChildRemoved Event is handled before the child is actually
  % removed.  Therefore we need to disable only if there is one child left.
  if (length(annotations) == 1) 
    set(menus(1),'enable','off');
  end
  % If all the Children are getting removed, turn on the Edit State
  selectedAnnotations = findobj(annotations,'Selected','on');
  if length(annotations) == length(selectedAnnotations)
    toolbar = findall(this.Figure,'type','uitoolbar');
    allToggleTools = findall(get(toolbar,'Children'),'Type','uitoggletool');
    selAnnotTool = findobj(allToggleTools,'Tag','select annotations');
    set(allToggleTools,'State','off');
    set(selAnnotTool,'State','on');
  end
  set(this.Figure,'Pointer','arrow');
end

function lineAdded(hSrc,event, this)
selectAllMenu = findall(this.EditMenu,'Tag','select all');
set(selectAllMenu,'enable','on');
toolbar = findall(this.Figure,'type','uitoolbar');
toolButton = findall(toolbar,'State','on');
%set(toolButton,'State','off');
%set(this.Figure,'Pointer','arrow');

function deleteAllDataTips(hSrc,event,this)
lblHandles = [];
if isa(this.State,'MapViewer.DataTipState') &&...
  ~isempty(this.State.LabelHandles)
  lblHandles = this.State.LabelHandles;
  delete([lblHandles{:,2}]);
  delete([lblHandles{:,3}]);
  lblHandles = [];
  this.State.LabelHandles = lblHandles;
elseif ~isempty(this.PreviousDataTipState) &&...
  ~isempty(this.PreviousDataTipState.LabelHandles)
  lblHandles = this.PreviousDataTipState.LabelHandles;
  lblHandles = this.PreviousDataTipState.LabelHandles;
  delete([lblHandles{:,2}]);
  delete([lblHandles{:,3}]);
  lblHandles = [];
  this.PreviousDataTipState.LabelHandles = lblHandles;
end

function closeAllInfoBox(hSrc,event,this)

if isa(this.State,'MapViewer.InfoToolState') &&...
      ~isempty(this.State.InfoBoxHandles)
  this.State.closeAll;
elseif ~isempty(this.PreviousInfoToolState) &&...
      ~isempty(this.PreviousInfoToolState.InfoBoxHandles)
  this.PreviousInfoToolState.closeAll;
end

function localShowHelp(hSrc,event,topic)

try
  helpview(fullfile(docroot,'toolbox','map','map.map'),'mapviewref');
catch
  message = sprintf('Unable to display help for the MapViewer.');
  errordlg(message);
end
