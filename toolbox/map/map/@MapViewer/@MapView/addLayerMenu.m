function layersMenu = addLayerMenu(viewer,layer)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/03/24 20:41:01 $

layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');

newLayersMenu = rebuildLayersMenu(viewer,layersMenu);
addMenu(viewer,newLayersMenu,layer);
enableMenuItems(viewer);


function addMenu(viewer,layersMenu,layer)
newMenu = uimenu('Parent',layersMenu,'Label',layer.getLayerName,...
                 'Position',1);

% To ensure that "Active" is appropriately checked for the layer menu
if strcmp(viewer.getActiveLayerName,layer.getLayerName) 
  isActive = 'on';
else
  isActive = 'off';
end

uimenu('Parent',newMenu,'Label','Active','Tag','make active',...
       'Position',1,'Callback',{@localMakeActive viewer layer.getLayerName},...
       'Checked',isActive);

visibility = get(layer,'visible'); 
uimenu('Parent',newMenu,'Label','Visible','Tag','visible',...
       'Checked',visibility,...
       'Position',2,'Callback',{@localMakeVisible viewer layer.getLayerName});

isBoundingBox = layer.getShowBoundingBox;
uimenu('Parent',newMenu,'Label','Bounding Box','Tag','bounding box',...
       'Checked',isBoundingBox,...
       'Position',3,'Callback',{@localShowBoundingBox viewer layer.getLayerName});

uimenu('Parent',newMenu,'Label','To Top','Tag','to top','Separator','on',...
       'Position',4,'Callback',{@localToTop viewer layer.getLayerName});

uimenu('Parent',newMenu,'Label','To Bottom','Tag','to bottom',...
       'Checked','off',...
       'Position',5,'Callback',{@localToBottom viewer layer.getLayerName});

uimenu('Parent',newMenu,'Label','Move Up','Tag', 'move up',...
       'Callback',{@localMoveUp viewer layer.getLayerName},...
       'Position',6,'Enable','off');

uimenu('Parent',newMenu,'Label','Move Down','Tag','move down',...
       'Position',7,'Callback',{@localMoveDown viewer layer.getLayerName});

uimenu('Parent',newMenu,'Label','Remove','Tag','remove','Separator','on',...
       'Position',8,'Callback',{@localRemoveLayer viewer layer});

uimenu('Parent',newMenu,'Label','Set Symbol Spec...','Tag','set symbols',...
       'Position',9,'Callback',{@openLegendDialog viewer layer},...
       'Checked','off');

nextInd = 10;
if ~isa(layer,'MapModel.RasterLayer')
  uimenu('Parent',newMenu,'Label','Set Label Attribute...','Tag','set attribute',...
         'Position',nextInd,'Callback',{@localSetLabelAttribute viewer layer},...
         'Checked','off');
  nextInd = nextInd + 1;
end

% $$$ uimenu('Parent',newMenu,'Label','Change Layer Name...','Tag','rename','Separator','on',...
% $$$        'Position',nextInd,'Callback',{@changeLayerName viewer layer});

%----------Callbacks----------%
function openLegendDialog(hSrc,event,viewer,layer)

h = figure('NumberTitle','off',...
           'IntegerHandle','off',...
           'Name','Layer Symbols',...
           'Menubar','none',...
           'Units','inches',...
           'Resize','off',...
           'Position',getWindowPosition(viewer,3,2),...
           'HandleVisibility','off',...
           'WindowStyle','modal');

backgroundColor = get(h,'Color');

uicontrol('Parent',h,'Style','Text',...
          'String',['Choose a layer symbolization structure',...
                    ' for the ' layer.getLayerName ' layer.'],...
          'Units','inches','Position',[0 1.5 3 0.4],...
          'BackgroundColor',backgroundColor);


symbolSpecs = uicontrol('Parent',h,'Style','list',...
                        'Units','inches','Position',[0.05 0.4 2.95 1]);

specNames = '';
workspaceVars = evalin('base','whos');
workspaceVarNames = {workspaceVars.name};
j = 1;
for i=1:length(workspaceVars)
  fcn = ['mapgate(' '''isvalidsymbolspec''' ',' workspaceVarNames{i} ');' ];
  if evalin('base', fcn)
    specNames{j} = workspaceVarNames{i};
    j = j+1;
  end
end
set(symbolSpecs,'String',specNames);


uicontrol('Parent',h,'Style','pushbutton',...
          'Units','inches','Position',[0.7 0.05 0.7 0.3],...
          'String','OK',...
          'Callback',{@setMapLegendOK symbolSpecs viewer layer});

uicontrol('Parent',h,'Style','pushbutton',...
          'Units','inches','Position',[1.7 0.05 0.7 0.3],...
          'String','Cancel',...
          'Callback',@setMapLegendCancel);

function setMapLegendCancel(hSrc,event)
close(get(hSrc,'Parent'));

function setMapLegendOK(hSrc,event,symbolSpecs,viewer,layer)
listStrs = get(symbolSpecs,'String');
if ~isempty(listStrs)
  listValue = get(symbolSpecs,'Value');
  specName = listStrs{listValue};
  symbolspec = evalin('base',specName);
  if isstruct(symbolspec)
    try
      layerlegend = layer.legend;
      origPropValues = get(layerlegend);
      layerlegend.override(rmfield(symbolspec,'ShapeType'));
    catch
      fprintf(1,'There error is here %s\n',mfilename);
      errordlg(lasterr,'Symbol Spec Error','modal');
      return;
    end
  else
    errordlg(sprintf('%s is not a valid Symbol Spec Structure.',specName),...
             'Symbol Spec Error','modal');
    return
  end
  
  try
    lasterr('');
    viewer.Map.setLayerLegend(layer.getLayerName,layerlegend);
    % Errors aren't caught when in listener callbacks. If there is an error,
    % the legend is not set, but there is no feedback from the legend
    % listener. So, we must check for an error by checking if lasterr is
    % empty.
    if isempty(lasterr)
      close(get(hSrc,'Parent'));
    else
      errordlg(lasterr,'Layer Symbol Error','modal');
      % restore previous values of the legend
      layerlegend.override(origPropValues);
    end
  catch
    errordlg(lasterr,'Layer Symbol Error','modal');
    return;
  end
else
  close(get(hSrc,'Parent'));
end

function localSetLabelAttribute(hSrc,event,viewer,layer)
attrNames = layer.getAttributeNames;

widthInInches = 2.5;
heightInInches = 3;

% Find the center of the viewer.
oldUnits = viewer.Figure.Units;
viewer.Figure.Units = 'inches';
viewerPos = viewer.Figure.Position;
centerX = viewer.Figure.Position(1) + viewer.Figure.Position(3)/2;
centerY = viewer.Figure.Position(2) + viewer.Figure.Position(4)/2;
viewer.Figure.Units = oldUnits;

% Add memory to the uicontrol
activeLayerHandles = handle(viewer.Axis.getLayerHandles(layer.getLayerName));
attr = [];
if ~isempty(activeLayerHandles);
  attr = get(activeLayerHandles(1),'DataTipAttribute');
end
if isempty(attr)
  stridx = 1;
else
  stridx = strmatch(attr, attrNames,'exact');
end

x = centerX - widthInInches/2;
y = centerY - heightInInches/2;
f = figure('Units','inches',...
           'Position',[x y widthInInches heightInInches],...
           'NumberTitle','off',...
           'Name','Attribute Names',...
           'IntegerHandle','off',...
           'WindowStyle','modal');
lb = uicontrol('Style','listbox','Parent',f,'Units','normalized',...
               'Position',[0.05 0.25 0.9 0.7],...
               'String',attrNames,...
               'Min',1,'Max',1,... % Single Selection
               'Value',stridx,...
               'UserData',layer.getLayerName);
%'Callback',{@setLayerLabel viewer},...

numOfbuttons = 2;
buttonWidth = 0.25;
buttonSpacing = 0.005;
leftMargin = (1 - numOfbuttons*(buttonWidth+2*buttonSpacing))/numOfbuttons;

done = uicontrol('Style','pushbutton','Parent',f,'Units','normalized',...
                 'Position',[leftMargin 0.05 buttonWidth 0.1],...
                 'String','OK',...
                 'Callback',{@setLayerLabel viewer lb f});
cancel = uicontrol('Style','pushbutton','Parent',f,'Units','normalized',...
                 'Position',[leftMargin + buttonWidth+2*buttonSpacing,...
                             0.05 buttonWidth 0.1],...
                 'String','Cancel',...
                 'Callback',{@delete f});


function setLayerLabel(hSrc,event,viewer,listbx,f)
val = get(listbx,'Value');
strings = get(listbx,'String');
activeLayerHandles = handle(viewer.Axis.getLayerHandles(get(listbx, ...
                                                  'UserData')));
set(activeLayerHandles,'DataTipAttribute',strings{val});
delete(f);

function localMakeActive(hSrc,event,viewer,layerName)
if strcmp(get(hSrc,'Checked'),'on')
  setActiveLayer(viewer,'None');
else
  setActiveLayer(viewer,layerName);
end

function localMoveUp(hSrc,event,viewer,layerName)
% Re-order layers in the map
layerOrder = viewer.Map.getLayerOrder;
idx = strmatch(layerName,layerOrder,'exact');
tmp = layerOrder{idx};
layerOrder{idx} = layerOrder{idx - 1};
layerOrder{idx - 1} = tmp;
viewer.Map.setLayerOrder(layerOrder);

% Re-order menu items
menuItem = get(hSrc,'Parent');
pos = get(menuItem,'Position');
set(menuItem,'Position',pos - 1);

% Rebuild Layers Menu - Remove when HG bug with UIMENU's is fixed.
layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');
newLayersMenu = rebuildLayersMenu(viewer,layersMenu);

enableMenuItems(viewer);

function localMoveDown(hSrc,event,viewer,layerName)
% Re-order layers in the map
layerOrder = viewer.Map.getLayerOrder;
idx = strmatch(layerName,layerOrder,'exact');
tmp = layerOrder{idx};
layerOrder{idx} = layerOrder{idx + 1};
layerOrder{idx + 1} = tmp;
viewer.Map.setLayerOrder(layerOrder);

% Re-order menu items
menuItem = get(hSrc,'Parent');
pos = get(menuItem,'Position');
set(menuItem,'Position',pos + 1);

% Rebuild Layers Menu - Remove when HG bug with UIMENU's is fixed.
layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');
newLayersMenu = rebuildLayersMenu(viewer,layersMenu);

enableMenuItems(viewer);

function localToBottom(hSrc,event,viewer,layerName)
% Re-order layers in the map
layerOrder = viewer.Map.getLayerOrder;
layerOrder(strmatch(layerName,layerOrder,'exact')) = [];
newLayerOrder = {layerOrder{:},layerName};
viewer.Map.setLayerOrder(newLayerOrder);

% Re-order menu items
layersMenu = findall(viewer.Figure,'Tag','layers');
numChildren = length(get(layersMenu,'Children'));
menuItem = get(hSrc,'Parent');
set(menuItem,'Position',numChildren);

% Rebuild Layers Menu - Remove when HG bug with UIMENU's is fixed.
layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');
newLayersMenu = rebuildLayersMenu(viewer,layersMenu);

enableMenuItems(viewer);

function localToTop(hSrc,event,viewer,layerName)
% Re-order layers in the map
layerOrder = viewer.Map.getLayerOrder;
layerOrder(strmatch(layerName,layerOrder,'exact')) = [];
newLayerOrder = {layerName, layerOrder{:}};
viewer.Map.setLayerOrder(newLayerOrder);

% Re-order menu items
menuItem = get(hSrc,'Parent');
set(menuItem,'Position',1);

% Rebuild Layers Menu - Remove when HG bug with UIMENU's is fixed.
layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');
newLayersMenu = rebuildLayersMenu(viewer,layersMenu);

enableMenuItems(viewer);

function localShowBoundingBox(hSrc,event,viewer,layerName)
state = get(gcbo,'Checked');
if strcmp(state,'on')
  set(gcbo,'Checked','off')
  viewer.Map.setShowBoundingBox(layerName,false);
else
  set(gcbo,'Checked','on')
  layer = viewer.Map.getLayer(layerName);
  layer.renderBoundingBox(viewer.Axis);
  viewer.Map.setShowBoundingBox(layerName,true);
end

function localMakeVisible(hSrc,event,viewer,layerName)
state = get(gcbo,'Checked');
if strcmp(state,'on')
  set(gcbo,'Checked','off')
  viewer.Map.setLayerVisible(layerName,false);
else
  set(gcbo,'Checked','on')
  viewer.Map.setLayerVisible(layerName,true);
end

function localRemoveLayer(hSrc,event,viewer,layer)

% Change to None if the layer is the active layer
if strcmp(viewer.ActiveLayerName,layer.getLayerName)
  viewer.setActiveLayer('None');
end
viewer.removeLayer(layer.getLayerName);

% Rebuild Layers Menu - Remove when HG bug with UIMENU's is fixed.
layersMenu = findall(viewer.Figure, 'Type','uimenu','Tag','layers');
newLayersMenu = rebuildLayersMenu(viewer,layersMenu);

enableMenuItems(viewer)

%----------Helper Functions----------%
function enableMenuItems(viewer)
layersMenu = findall(viewer.Figure,'Tag','layers');
numChildren = length(get(layersMenu,'Children'));
if numChildren == 1
  disableMoveMenuItems(viewer);
else
  enableTopMenuItems(viewer);
  enableMiddleMenuItems(viewer);
  enableBottomMenuItems(viewer);
end

function disableMoveMenuItems(viewer)
layersMenu = findall(viewer.Figure,'Tag','layers');
topMenu = findall(viewer.Figure,'Parent',layersMenu,'Position',1);
toTopMenu = findall(topMenu,'Tag','to top');
set(toTopMenu,'Enable','off');
toBottomMenu = findall(topMenu,'Tag','to bottom');
set(toBottomMenu,'Enable','off');
moveUpMenu = findall(topMenu,'Tag','move up');
set(moveUpMenu,'Enable','off');
moveDownMenu = findall(topMenu,'Tag','move down');
set(moveDownMenu,'Enable','off');

function enableMiddleMenuItems(viewer)
layersMenu = findall(viewer.Figure,'Tag','layers');
children = get(layersMenu,'Children');
for i=1:length(children)
  pos = get(children(i),'Position');
  if (pos ~= 1) && (pos ~= length(children))
    toTopMenu = findall(children(i),'Tag','to top');
    set(toTopMenu,'Enable','on');
    toBottomMenu = findall(children(i),'Tag','to bottom');
    set(toBottomMenu,'Enable','on');
    moveUpMenu = findall(children(i),'Tag','move up');
    set(moveUpMenu,'Enable','on');
    moveDownMenu = findall(children(i),'Tag','move down');
    set(moveDownMenu,'Enable','on');
  end
end

function enableTopMenuItems(viewer)
layersMenu = findall(viewer.Figure,'Tag','layers');
topMenu = findall(viewer.Figure,'Parent',layersMenu,'Position',1);
toTopMenu = findall(topMenu,'Tag','to top');
set(toTopMenu,'Enable','off');
toBottomMenu = findall(topMenu,'Tag','to bottom');
set(toBottomMenu,'Enable','on');
moveUpMenu = findall(topMenu,'Tag','move up');
set(moveUpMenu,'Enable','off');
moveDownMenu = findall(topMenu,'Tag','move down');
set(moveDownMenu,'Enable','on');

function enableBottomMenuItems(viewer)
layersMenu = findall(viewer.Figure,'Tag','layers');
%topMenu = findall(viewer.Figure,'Parent',layersMenu,'Position',1);
numChildren = length(get(layersMenu,'Children'));
bottomMenu = findall(viewer.Figure,'Parent',layersMenu,...
                     'Position',numChildren);
toTopMenu = findall(bottomMenu,'Tag','to top');
set(toTopMenu,'Enable','on');  
toBottomMenu = findall(bottomMenu,'Tag','to bottom');
set(toBottomMenu,'Enable','off');
moveUpMenu = findall(bottomMenu,'Tag','move up');
set(moveUpMenu,'Enable','on');
moveDownMenu = findall(bottomMenu,'Tag','move down');
set(moveDownMenu,'Enable','off');


function newLayersMenu = rebuildLayersMenu(viewer,layersMenu)
newLayersMenu = uimenu('Parent',viewer.Figure,'Label','Layers',...
                       'Tag','layers','Position',6);
layerMenuChildren = get(layersMenu,'Children');
for i=1:length(layerMenuChildren)
  l = viewer.getMap.getLayer(get(layerMenuChildren(i),'Label'));
  addMenu(viewer,newLayersMenu,l);
end
delete(layersMenu)

%--------------------------------------------------%
function p = getWindowPosition(viewer,w,h)
p = viewer.getPosition('inches');
x = p(1) + p(3)/2 - 2.8/2;
y = p(2) + p(4)/2 - h/2;
p = [x,y,w,h];


function changeLayerName(hSrc,event,viewer,layer)

h = figure('NumberTitle','off',...
           'IntegerHandle','off',...
           'Name','Change Layer Name',...
           'Menubar','none',...
           'Units','inches',...
           'Resize','off',...
           'Position',getWindowPosition(viewer,3,1.5),...
           'HandleVisibility','off',...
           'WindowStyle','modal');

backgroundColor = get(h,'Color');

uicontrol('Parent',h,'Style','Text',...
          'String','Enter new layer name:',...
          'HorizontalAlignment','left',...
          'Units','inches','Position',[0.25 0.9 2.5 0.3],...
          'BackgroundColor',backgroundColor);

str = uicontrol('Parent',h,'Style','Edit',...
                'HorizontalAlignment','left',...
                'String',layer.LayerName,...
                'Units','inches','Position',[0.25 0.6 2.5 0.3],...
                'BackgroundColor','white');

layerMenu = get(hSrc,'Parent');

okButton = uicontrol('Parent',h,'Style','pushbutton',...
                     'Units','inches','Position',[0.7 0.05 0.7 0.3],...
                     'String','OK','Callback',{@doOkLayerName,h,str,layer,...
                    layerMenu,viewer});

cancelButton = uicontrol('Parent',h,'Style','pushbutton',...
                         'Units','inches','Position',[1.7 0.05 0.7 0.3],...
                         'String','Cancel','Callback',{@doCancelLayerName h});

function doOkLayerName(hSrc,event,f,str,lyr,lyrMenu,viewer,isActiveLayer)
%Changes the layer Name globally by doing the following:
%  * changes the layerName of the layer object
%  * changes the layerName of the graphics objects for the layer
%  * changes the active layer pop-up menu
%  * changes the layerName configuration stored in the map model
%  * changes the activeLayer if the layer is active
%  * changes the layer names in the DataTipState LabelHandles
%  * changes the layer names in the InfoToolState boxHandles
%  * changes the name of the layer menu

newLayerName = get(str,'String');
lyrNameDisp = viewer.DisplayPane.ActiveLayerDisplay;

%Change the layer names in the LabelHandles of the DataTips
if strcmp(class(viewer.State),'MapViewer.DataTipState') &&...
      ~isempty(viewer.State.LabelHandles)
  labelHand = viewer.State.LabelHandles;
  idx = strmatch(lyr.LayerName,labelHand(:,1),'exact');
  labelHand{idx,1} = newLayerName;
  viewer.State.LabelHandles = labelHand;
elseif ~isempty(viewer.PreviousDataTipState) &&...
  ~isempty(viewer.PreviousDataTipState.LabelHandles)
  labelHand = viewer.PreviousDataTipState.LabelHandles;
  idx = strmatch(lyr.LayerName,labelHand(:,1),'exact');
  labelHand{idx,1} = newLayerName;
  viewer.PreviousDataTipState.LabelHandles = labelHand;
end

%Change the layer names in the InfoBoxHandles of the Info
if strcmp(class(viewer.State),'MapViewer.InfoToolState') &&...
      ~isempty(viewer.State.InfoBoxHandles)
  infoBoxHandles = viewer.State.InfoBoxHandles;
  idx = strmatch(lyr.LayerName,infoBoxHandles(:,1),'exact');
  infoBoxHandles{idx,1} = newLayerName;
  viewer.State.InfoBoxHandles = infoBoxHandles;
elseif ~isempty(viewer.PreviousInfoToolState) &&...
      ~isempty(viewer.PreviousInfoToolState.InfoBoxHandles)
  infoBoxHandles = viewer.PreviousInfoToolState.InfoBoxHandles;
  idx = strmatch(lyr.LayerName,infoBoxHandles(:,1),'exact');
  infoBoxHandles{idx,1} = newLayerName;
  viewer.PreviousInfoToolState.InfoBoxHandles = infoBoxHandles;
end

%Change the Active Layer popup menu 
strs = get(lyrNameDisp,'String');
idx1 = strmatch(lyr.LayerName,strs,'exact');
strs(idx1) = {newLayerName};
set(lyrNameDisp,'String',strs);

%Check if the changed layer is the active layer
if strcmp(lyr.LayerName,viewer.ActiveLayerName)
  viewer.ActiveLayerName = newLayerName;
end

%Get the layers from the MapModel
lyrOrder = viewer.getMap.getLayerOrder;
idx2 = strmatch(lyr.LayerName,lyrOrder);
lyrOrder(idx2) = {newLayerName};

%Get the graphics on the viewer Axis
lyrHandles = handle(get(viewer.Axis,'Children'));
idx3 = strmatch(lyr.LayerName,[get(lyrHandles,'LayerName')],...
               'exact');

%Change the LayerName property of the graphics
for n = idx3'
  lyrHandles(n).setLayerName(newLayerName);
end

%Change the name of the layers in the model
setMapLayerOrder(viewer,lyrOrder);

%change the name of the layer itself
lyr.setLayerName(newLayerName);

%Change the name of the layer menu
set(lyrMenu,'Label',newLayerName);

close(f);

function doCancelLayerName(hSrc,event,f)
close(f);

function setMapLayerOrder(viewer,lyrOrder)
viewer.getMap.Configuration = lyrOrder(:);

