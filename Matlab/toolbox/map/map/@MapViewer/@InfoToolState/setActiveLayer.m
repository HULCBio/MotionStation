function setActiveLayer(this,viewer,activeLayerName)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:40 $

if ~isempty(viewer.ActiveLayerName)
  % "Turn off" current active handles
  activeLayerHandles = handle(viewer.Axis.getLayerHandles(viewer.ActiveLayerName));
  set(activeLayerHandles,'ButtonDownFcn','');
end

activeLayerHandles = handle(viewer.Axis.getLayerHandles(activeLayerName));
set(activeLayerHandles,'ButtonDownFcn',{@showInfoBox this viewer activeLayerHandles});
set(viewer.Figure,'WindowButtonDownFcn','');
set(viewer.Figure,'WindowButtonUpFcn','');

function showInfoBox(hSrc,event,this,viewer,activeLayerHandles)
%allows only left clicks
if ~strcmp('normal',viewer.Figure.SelectionType)
  return
end
p = viewer.getMapCurrentPoint;
layerGraphics = handle(hSrc);
layer = viewer.getMap.getLayer(activeLayerHandles(1).LayerName);

S = getShapeStruct(layerGraphics,layer);
found = false;
if ~isempty(this.InfoBoxHandles)
  tmp = this.InfoBoxHandles;
  idx1 = strmatch(layerGraphics.LayerName,tmp(:,1));
  boxNames = get([tmp{idx1,2}],'Name');
  if isstr(boxNames)
    boxNames = {boxNames};
  end
  for n = 1:length(boxNames)
    newName = [layerGraphics.LayerName,' feature ', num2str(S.INDEX)];
    if strcmp(boxNames{n},newName)
      figure(this.InfoBoxHandles{idx1,2}(n));
      found = true;
    end
  end
end

if ~found
  f = infobox(layerGraphics.LayerName,S,S.INDEX,this);
  set(f,'DeleteFcn',{@removeFromHandleList this}); 
  addHandleToList(this,layerGraphics.LayerName,f);
end

%---------------------------------------------------------------------------
function shpStruct = getShapeStruct(layerGraphics,layer)
attrNames = layer.Components.AttributeNames;
for i = 1:length(attrNames)
  %  if ~strcmp('X',attrNames{i}) && ~strcmp('Y',attrNames{i})
  shpStruct.(attrNames{i}) = layerGraphics.getAttribute(attrNames{i});
  %  end
end

%---------------------------------------------------------------------------
function f = infobox(layername,s,n,this)
% Create a figure displaying information about the N-th element of
% geographic structure array S, in layer LAYERNAME.

f = figure('Menubar','none','NumberTitle','off',...
           'IntegerHandle','off','Color','w',...
           'Name',[layername ' feature ' num2str(n)],...
           'Visible','off');


pos = getWindowPosition(this);
set(f,'Units','pixels','Position',pos);
% Shrink the figure to 60% of its default size.
%p = get(f,'Position');
%set(f,'Position',[1 1 0.6 0.6].*p);

mytext = struct2strs(s)';

% Pad top and bottom with blank lines; pad left with blank column.
mytext = [{''} mytext {''}];
mytext = cellstr([repmat('  ',[length(mytext) 1]) char(mytext)]);

h = uicontrol('Style','text','Units','normal','Position',[0 0 1 1],...
    'Parent',f,'String',mytext,'BackgroundColor','w',...
    'HorizontalAlignment','left','FontName','fixedwidth');

% Increase the font size relative to the default.
fontsize = get(h,'FontSize');
set(h,'FontSize',fontsize + 4);
set(f,'Visible','on');
set(f,'HandleVisibility','off');
set(h,'HandleVisibility','off');

%---------------------------------------------------------------------------
function strs = struct2strs(s)
% s is a 1-by-1 struct.

% Construct an array of right-justified display names
names = fieldnames(s);
maxNameLength = 0;
dnames = cell(numel(names),1);
for k = 1:numel(names)
    maxNameLength = max(maxNameLength,length(names(k)));
    dnames{k} = fliplr(names{k});
end
dnames = cellstr(fliplr(strvcat(dnames)));

% Determine a display value for each field and
% concatenate it with the display name.
strs = cell(numel(names),1);
for k = 1:numel(names)
    v = s.(names{k});
    if numel(v) == 1 && isnumeric(v)
        dvalue = num2str(v);
    elseif isstr(v)
        dvalue = ['''' v ''''];
    else
        sz = size(v);
        cl = class(v);
        dvalue = ['[' num2str(sz(1)) 'x' num2str(sz(2)) ' ' cl ']'];
    end
    strs{k} = [dnames{k} ': ' dvalue];
end

%---------------------------------------------------------------------------
function pos = getWindowPosition(this)
pos = this.Viewer.getPosition('pixels');

w = 225;
h = 187;
x = pos(1) + pos(3) - (w+25);
y = pos(2) + pos(4) - (h+25);
pos = [x,y,w,h];
pos = cascadeInfoBoxes(this,pos,-45,-45);

%---------------------------------------------------------------------------
function p = cascadeInfoBoxes(this,Position,movX,movY)
p = Position;
tmp = this.InfoBoxHandles;
if isempty(tmp)
  return
end
infoBoxes = [tmp{:,2}];
for i=1:length(infoBoxes)
  oldunits = get(infoBoxes(i),'Units');
  set(infoBoxes(i),'Units','pixels');
  boxPos = get(infoBoxes(i),'Position');
  set(infoBoxes(i),'Units',oldunits);
  if isequal(boxPos(1),Position(1)) &&...
        isequal(boxPos(2),Position(2))
    p(1) = Position(1) + movX;
    p(2) = Position(2) + movY; 
   
    rootScreenSize = get(0,'ScreenSize');
    % (position is [x(from left) y(bottom edge from bottom) width height]
    % check left edge and right edge
    if (p(1) < 1)
      movX = 45;
    end
    if(p(1) + p(3) > rootScreenSize(3))
      movX = 45;
    end    
    if (p(2) < 1)
      movY = 45;
    end    
    if (p(2) + p(4) > rootScreenSize(4))
      movY = 45;
    end

    p = cascadeInfoBoxes(this,p,movX,movY); 
  end
end

%---------------------------------------------------------------------------
function addHandleToList(this,name,h)
if isempty(this.InfoBoxHandles)
    this.InfoBoxHandles{1,1} = name;
    this.InfoBoxHandles{1,2} = h;
else
  i = strmatch(name,this.InfoBoxHandles(:,1),'exact');
  if ~isempty(i)
    nextHandleIdx = length(this.InfoBoxHandles{i,2}) + 1;
    this.InfoBoxHandles{i,2}(nextHandleIdx) = h;
  else
    nextRow = size(this.InfoBoxHandles,1) + 1;
    this.InfoBoxHandles{nextRow,1} = name;
    this.InfoBoxHandles{nextRow,2} = h;
  end
end

function removeAllFromHandleList(hSrc,event)
delete([this.InfoBoxHandles{:,2}]);
this.InfoBoxHandles = [];

function removeFromHandleList(hSrc,event, this)
for n = 1:length(this.InfoBoxHandles(:,1))
    tst = (hSrc == this.InfoBoxHandles{n,2});
    if any(tst), break, end
end
this.InfoBoxHandles{n,2}(tst) = [];
delete(hSrc);
