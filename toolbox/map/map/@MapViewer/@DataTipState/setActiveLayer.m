function setActiveLayer(this,viewer,activeLayerName)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:26 $

if ~isempty(viewer.ActiveLayerName)
  % "Turn off" current active handles
  activeLayerHandles = handle(viewer.Axis.getLayerHandles(viewer.ActiveLayerName));
  set(activeLayerHandles,'ButtonDownFcn','');
end

activeLayerHandles = handle(viewer.Axis.getLayerHandles(activeLayerName));
set(activeLayerHandles,'ButtonDownFcn',{@addDataTip this viewer activeLayerHandles});
set(viewer.Figure,'WindowButtonDownFcn','');
set(viewer.Figure,'WindowButtonUpFcn','');

this.ActiveLayerName = activeLayerName;

function addDataTip(hSrc,event,this,viewer,activeLayerHandles)
%allows only left clicks
if ~strcmp('normal',lower(viewer.Figure.SelectionType))
  return
end
p = viewer.getMapCurrentPoint;
layerHandle = handle(hSrc);
if isempty(layerHandle.DataTipAttribute) 
  lyr = viewer.getMap.getLayer(activeLayerHandles(1).LayerName);
  attrNames = lyr.getAttributeNames;
  set(activeLayerHandles,'DataTipAttribute',attrNames{1});
end
if ~strcmp(lower(this.ActiveLayerName),'none')
  str = layerHandle.getAttribute(layerHandle.DataTipAttribute);
  h = MapGraphics.Text('info','Parent',double(viewer.UtilityAxes),...
                       'String',str,...
                       'Position',[p 0],'EraseMode','normal','Color',[0 0 0],...
                       'BackgroundColor',[0.9 0.9 0],'Interpreter','none');
  contextmenu = createUIContextMenu(this,h);
  set(h,'UIContextMenu',contextmenu);
  
  addHandleToList(this,layerHandle.LayerName,h,contextmenu);
end

function addHandleToList(this,name,h,cmenu)
if isempty(this.LabelHandles)
    this.LabelHandles{1,1} = name;
    this.LabelHandles{1,2} = h;
    this.LabelHandles{1,3} = cmenu;
    
else
  i = strmatch(name,this.LabelHandles(:,1),'exact');
  if ~isempty(i)
    nextHandleIdx = length(this.LabelHandles{i,2}) + 1;
    this.LabelHandles{i,2}(nextHandleIdx) = h;
    this.LabelHandles{i,3}(nextHandleIdx) = cmenu;
  else
    nextRow = size(this.LabelHandles,1) + 1;
    this.LabelHandles{nextRow,1} = name;
    this.LabelHandles{nextRow,2} = h;
    this.LabelHandles{nextRow,3} = cmenu;
  end
end

%------Datatip Context Menu---------------------------------------------------%
function contextmenu = createUIContextMenu(this,textHandle)
contextmenu = uicontextmenu('Parent',this.Viewer.Figure);
removeMenu = uimenu('Parent',contextmenu,'Label','Delete datatip',...
                    'Callback',{@DeleteDatatip this textHandle});
removeMenu = uimenu('Parent',contextmenu,'Label','Delete all datatips',...
                    'Callback',{@DeleteAllDatatips this});

function DeleteDatatip(hSrc,event,this,textHandle)
for n = 1:length(this.LabelHandles(:,1))
    tst = (textHandle == this.LabelHandles{n,2});
    if any(tst), break, end
end
this.LabelHandles{n,2}(tst) = [];
this.LabelHandles{n,3}(tst) = [];
delete(textHandle);

function DeleteAllDatatips(hSrc,event,this)
delete([this.LabelHandles{:,2}]);
delete([this.LabelHandles{:,3}]);
this.LabelHandles = [];
