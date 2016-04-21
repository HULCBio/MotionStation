function createToolbar(this)
%CREATETOOLBAR Create toolbar for MapView

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:55 $

if ~isempty(findstr(version,'R14'))
  iconroot = [matlabroot '/toolbox/map/icons/'];
else
  % For R13 the toolbox/map/icons directory must be on the path.
  iconroot = '';
end

bgColor = get(this.Figure,'Color');

selectionIcon   = makeToolbarIconFromPNG([iconroot 'tool_select.png']);
zoomInIcon      = makeToolbarIconFromPNG([iconroot,'view_zoom_in.png']);
zoomOutIcon     = makeToolbarIconFromPNG([iconroot 'view_zoom_out.png']);
arrowIcon       = makeToolbarIconFromPNG([iconroot 'tool_arrow.png']);
lineIcon        = makeToolbarIconFromPNG([iconroot 'tool_line.png']);
textIcon        = makeToolbarIconFromPNG([iconroot 'tool_text.png']);
fitToWindowIcon = makeToolbarIconFromPNG([iconroot 'view_fit_to_window.png']);
datatipIcon     = makeToolbarIconFromPNG([iconroot 'tool_datatip.png']);
panIcon         = makeToolbarIconFromPNG([iconroot 'tool_hand.png']);
prevViewIcon    = makeToolbarIconFromPNG([iconroot 'view_prev.png']);
selectAreaIcon  = makeToolbarIconFromPNG([iconroot 'tool_marquee.png']);
infoToolIcon    = makeToolbarIconFromPNG([iconroot 'info.png']);

if ~isempty(findstr(version,'R14'))
  toolbar = uitoolbar('Parent',this.Figure);
  printTool = uitoolfactory(toolbar,'Standard.PrintFigure');
else
  toolbar = findall(this.Figure,'type','uitoolbar');
  hiddenHandles = get(0,'ShowHiddenHandles');
  set(0,'ShowHiddenHandles','on');
  tools = get(toolbar,'Children');
  set(0,'ShowHiddenHandles',hiddenHandles);
  printTool = tools(8);
  delete(tools([1 2 3 4 5 6 7 9 10 11]));
end  

set(printTool,'TooltipString','Print figure');
set(printTool,'ClickedCallback',{@localPrint, this});

selectionTool = uitoggletool(toolbar,...
                             'Cdata',selectionIcon,...
                             'TooltipString','Select annotations',...
                             'Tag','select annotations',...
                             'State','on','Enable','on',...
                             'ClickedCallback',@ClickedCallback,...
                             'OnCallback',{@initEditState this},...
                             'OffCallback',{@endEditState this});

rectTool = createToolbarToggleItem(toolbar,selectAreaIcon,...
                                   {@initSelectAreaState this},...
                                   'Select area',{@endSelectAreaState this});


zoomInTool = createToolbarToggleItem(toolbar,zoomInIcon,...
                                     {@initZoomInState this},...
                                     'Zoom in',{@endZoomInState this});

zoomOutTool = createToolbarToggleItem(toolbar,zoomOutIcon,...
                                     {@initZoomOutState this},...
                                     'Zoom out',{@endZoomOutState this});

panTool = createToolbarToggleItem(toolbar,panIcon,...
                                  {@initPanState this},'Pan tool',...
                                  {@endPanState this});

insertTextItem = createToolbarToggleItem(toolbar,textIcon,...
                                         {@initInsertTextState this},...
                                         'Insert text',...
                                         {@endInsertTextState this});

insertArrowItem = createToolbarToggleItem(toolbar,arrowIcon,...
                                          {@initInsertArrowState this},...
                                          'Insert arrow',...
                                          {@endInsertArrowState this});

insertLineItem = createToolbarToggleItem(toolbar,lineIcon,...
                                         {@initInsertLineState this},...
                                         'Insert line',...
                                         {@endInsertLineState this});

dataTipTool = createToolbarToggleItem(toolbar,datatipIcon,...
                                      {@initDatatipState this},...
                                      'Datatip tool',{@endDatatipState this});

infoTool = createToolbarToggleItem(toolbar,infoToolIcon,...
                                      {@initInfoToolState this},...
                                      'Info tool',{@endInfoToolState this});

backTool = createToolbarPushItem(toolbar,prevViewIcon,...
                                 {@doBackToPreviousView this},...
                                 'Back to previous view');

fitToWindowItem = createToolbarPushItem(toolbar,fitToWindowIcon,...
                                        {@doFitToWindow this},'Fit to window');

set(selectionTool, 'Separator','on');
set(zoomInTool,    'Separator','on');
set(insertTextItem,'Separator','on');
set(dataTipTool,   'Separator','on');
set(backTool,      'Separator','on');

if ~isempty(findstr(version,'R14'))

else
  set(toolbar,'Children',...
              [fitToWindowItem,backTool,infoTool,dataTipTool,...
               insertLineItem,insertArrowItem,insertTextItem,...
               panTool,zoomOutTool,zoomInTool,rectTool,selectionTool,...
               printTool]);
end

%----------Callbacks----------%

% Start Tools / Initialize States

% Functions initializing a state should follow this template:
%
%  function initXYZState(hSrc,event,viewer,...)
%  delete(viewer.State);
%  viewer.setDefaultState;
%  viewer.State = PKG.XYZState(...);
%

function localPrint(hSrc,event,this)
this.printMap;

function initDatatipState(hSrc,event,viewer)
changeStateToDefault(viewer);
showUsage = true;
if ispref('MathWorks_MapViewer','ShowDatatipUsage')
  if ~getpref('MathWorks_MapViewer','ShowDatatipUsage')
    showUsage = false;
  end
end
if ~viewer.Preferences.ShowDatatipUsage
  showUsage = false;
end

if strcmp(lower(viewer.ActiveLayerName),'none') ||...
      isempty(viewer.ActiveLayerName)
  viewer.dataTipUsage('NoActiveLayer','Datatip Tool');
  set(hSrc,'State','off');
  viewer.setDefaultState;
  return
  %changeStateToDefault(viewer);
end
if showUsage
  viewer.dataTipUsage('Default');
end

viewer.State = MapViewer.DataTipState(viewer);
checkToolMenu(hSrc,'on');

function initSelectAreaState(hSrc,event,viewer)                         
changeStateToDefault(viewer);
viewer.State = MapViewer.SelectAreaState(viewer);
checkToolMenu(hSrc,'on');

function initZoomInState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.ZoomInState(viewer);
checkToolMenu(hSrc,'on');

function initZoomOutState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.ZoomOutState(viewer);
checkToolMenu(hSrc,'on');

function initPanState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.PanState(viewer);
checkToolMenu(hSrc,'on');

function initEditState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.EditState(viewer);
checkToolMenu(hSrc,'on');

function initInsertTextState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.InsertTextState(viewer);
checkToolMenu(hSrc,'on');

function initInsertArrowState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.InsertArrowState(viewer);
checkToolMenu(hSrc,'on');

function initInsertLineState(hSrc,event,viewer)
changeStateToDefault(viewer);
viewer.State = MapViewer.InsertLineState(viewer);
checkToolMenu(hSrc,'on');

function initInfoToolState(hSrc,event,viewer)                         
changeStateToDefault(viewer);
if strcmp(lower(viewer.ActiveLayerName),'none') ||...
      isempty(viewer.ActiveLayerName)
  viewer.dataTipUsage('NoActiveLayer','Info Tool');
  set(hSrc,'State','off');
  viewer.setDefaultState;
  return
  %changeStateToDefault(viewer);
end
viewer.State = MapViewer.InfoToolState(viewer);
checkToolMenu(hSrc,'on');


% End State
% The "Off Callback"  functions are called in the following order:
%
% Situation 1 - Deselect a selected item
%   The callback is executed immediately.
%
% Situation 2 - Select the item. Then select a different item (mutually exclusive)
%   New item's "On Callback" is executed (state is switched).
%   Old item's "Off Callback" is executed.
%  
% Because of Situation 2, the current state of the viewer must be queried before
% deleting it.  If the current state is the same as the state associated with
% the OffCallback, then it is Situation 1, and the current state should be
% deleted.  If it is Situation 2, then the state has been switched to another
% (non-default) state and the other state should handle deleting the current
% state. 
%
% Functions ending a state should follow this template:
%
%  function endXYZState(hSrc,event,viewer,...)
%  if strcmp(class(viewer.State),'PGH.XYZState');
%    delete(viewer.State);
%    viewer.setDefaultState;
%  end
%

function endDatatipState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.DataTipState');
  changeStateToDefault(viewer);
end

function endSelectAreaState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.SelectAreaState');
  changeStateToDefault(viewer);
end

function endEditState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.EditState')
  changeStateToDefault(viewer);
end

function endInsertTextState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.InsertTextState'); 
  changeStateToDefault(viewer);
end

function endInsertArrowState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.InsertArrowState');
  changeStateToDefault(viewer);
end

function endInsertLineState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.InsertLineState');
  changeStateToDefault(viewer);
end

function endPanState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.PanState')
  changeStateToDefault(viewer);
end

function endZoomInState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.ZoomInState')
  changeStateToDefault(viewer);
end

function endZoomOutState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.ZoomOutState')
  changeStateToDefault(viewer);
end

function endInfoToolState(hSrc,event,viewer)
if strcmp(class(viewer.State),'MapViewer.InfoToolState')
  changeStateToDefault(viewer);
end


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

% Toggle items that call ClickedCallback will be mutually exclusive.

function ClickedCallback(hSrc,event)
uiresume(get(get(hSrc,'Parent'),'Parent'));
hiddenHandles = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
tools = findall(get(get(hSrc,'Parent'),'Parent'),'type','uitoggletool');
set(0,'ShowHiddenHandles',hiddenHandles);
set(tools(tools ~= hSrc),'State','off');
if (strcmp(get(hSrc,'State'),'off'))
  selAnnot = findobj(tools,'tag','select annotations');
  set(selAnnot,'State','on');
end

%----------Helper Functions----------%
function item = createToolbarPushItem(toolbar,icon,callback,tooltip);
item = uipushtool(toolbar,...
                  'Cdata',icon,...
                  'TooltipString',tooltip,...
                  'Tag',lower(tooltip),...
                  'ClickedCallback',callback);

function item = createToolbarToggleItem(toolbar,icon,callback,...
                                        tooltip,offcallback);
item = uitoggletool(toolbar,...
                    'Cdata',icon,...
                    'TooltipString',tooltip,...
                    'Tag',lower(tooltip),...
                    'ClickedCallback',@ClickedCallback,...
                    'OnCallback',callback,...
                    'OffCallback',offcallback);

function icon = makeToolbarIconFromPNG(filename)
% Icon's background color is [0 1 1]
[icon,map] = imread(filename);
idx = 0;
for i=1:size(map,1)
  if all(map(i,:) == [0 1 1])
    idx = i;
    break;
  end
end
mask = icon==(idx-1); % Zero based.
[r,c] = find(mask);
icon = ind2rgb(icon,map);
for i=1:length(r)
  icon(r(i),c(i),:) = NaN;
end

function changeStateToDefault(viewer)
if isa(viewer.State,'MapViewer.DataTipState')
  viewer.PreviousDataTipState = viewer.State;
end

delete(viewer.State);
viewer.setDefaultState;

function checkToolMenu(toolbarItem, checked)
toolmenu = findobj(get(get(toolbarItem,'Parent'),'Parent'),...
                        'type','uimenu','Label','Tools');

set(get(toolmenu,'Children'),'Checked','off');
thisToolMenu = findobj(toolmenu,'Tag',[get(toolbarItem,'Tag'), ' menu']);

if strcmp(checked,'off')
  selectAnnotMenuItem = findobj(toolmenu,'Tag','select annotations menu');
  set(selectAnnotMenuItem,'Checked','on');
else
  if ~isempty(thisToolMenu)
    set(thisToolMenu,'Checked','on');
  end
end

function restoreDataTipContextMenu(viewer)
if ~isempty(viewer.PreviousDataTipState)
  for n = 1:length(viewer.PreviousDataTipState.LabelHandles(:,1))
    dataTipLabels = viewer.PreviousDataTipState.LabelHandles{n,2};
    dataTipContextMenus = viewer.PreviousDataTipSTate.LabelHandles{n,3};
    for ind = 1:length(dataTipLabels)
      set(dataTipLabels(ind),'uicontextMenu',dataTipContextMenus(ind));
    end
  end
end
