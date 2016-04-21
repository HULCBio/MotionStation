function h=colorbar(varargin)
%COLORBAR creates the scribe colorbar object

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.21 $  $  $

if (nargin == 0) || ischar(varargin{1})
  parind = find(strcmpi(varargin,'parent'));
  if isempty(parind)
    fig = gcf;
  else
    fig = varargin{parind(end)+1};
  end
  ax = get(fig,'CurrentAxes');
  if isempty(ax)
    ax = axes('parent',fig);
  end
else
  ax=varargin{1};
  fig = ancestor(ax,'figure');
  location=varargin{2};
  position=varargin{3};
  varargin(1:3) = [];
end
par = get(ax,'Parent');
% be sure nextplot is 'add'
oldNextPlot = get(fig,'NextPlot');
if strcmp(oldNextPlot,'replacechildren') | strcmp(oldNextPlot,'replace')
  set(fig,'NextPlot','add');
end
h = scribe.colorbar('Parent',par,'Units','normalized','visible','off','Interruptible','off');
b = hggetbehavior(double(h),'Pan');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Zoom');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Rotate3D');
set(b,'Enable',false);
b = hggetbehavior(double(h),'DataCursor');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Plotedit');
set(b,'MouseOverFcn',methods(h,'getfunhan','-noobj','mouseover'));
set(b,'ButtonDownFcn',methods(h,'getfunhan','-noobj','bdown'));
set(b,'KeepContextMenu',true);
set(b,'AllowInteriorMove',true);
set(double(h),'ButtonDownFcn',@resetCurrentAxes);

if ~isappdata(0,'BusyDeserializing')
  
  set(double(h),'Tag','Colorbar');
  
  % set units to normalized
  h.Units = 'normalized';
  
  h.Location = location;
  h.Axes = ax;
  h.BaseColormap = get(fig,'Colormap');
  
  % customize colorbar behavior for tools
  setappdata(double(h),'NonDataObject',[]);
  setappdata(double(h),'PostDeserializeFcn',graph2dhelper('colorbarpostdeserialize'));
  
  % THE AXES
  cbarax = double(h);
  set(cbarax,'Units','normalized', ...
             'Box', 'on');
  
  set(fig,'NextPlot',oldNextPlot);
  
  initialize_colorbar_properties(fig,ax,h,position);
  
  % init position before listeners are set up (why?)
  if ~isempty(position) && length(position)==4
    set(double(h),'Position',position);
  end
  
  % LISTENERS
  l= handle.listener(h,h.findprop('Location'),...
                     'PropertyPostSet',{@changedLocation,ax});
  l(end+1)= handle.listener(h,h.findprop('Position'),...
                            'PropertyPostSet',{@changedPos,h,'position'});
  l(end+1)= handle.listener(h,h.findprop('OuterPosition'),...
                            'PropertyPostSet',{@changedPos,h,'outerposition'});
  l(end+1)= handle.listener(h,h.findprop('Units'),...
                            'PropertyPretSet',{@changedUnits,h,'off'});
  l(end+1)= handle.listener(h,h.findprop('Units'),...
                            'PropertyPosttSet',{@changedUnits,h,'on'});
  l(end+1)= handle.listener(h,h.findprop('EdgeColor'),...
                            'PropertyPostSet',@changedEdgeColor);
  h.PropertyListeners = l;
  
  l = handle.listener(h,'ObjectBeingDestroyed',{@colorbarDeleted,h});
  h.DeleteListener = l;

  set(double(h),'visible','on');
  set(double(h.Image),'visible','on');

  methods(h,'set_contextmenu','on');

  % set other properties from varargin
  set(h,varargin{:});
  
  set(fig,'currentaxes',ax);   
  h.methods('startlisteners');  % installs peer axis listeners
  h.methods('auto_adjust_colors');
  
  % set correct state of cbar toggle and menuitem
  h.methods('update_toggle_and_menuitem');    
  legendcolorbarlayout(ax,'on')
  legendcolorbarlayout(ax,'layout')
end

%----------------------------------------------------------------------%
% Callback fired when EdgeColor changes. Updates X and Y Color.
function changedEdgeColor(hProp,eventData)
h=eventData.affectedObject;
c = get(h,'EdgeColor');
set(h,'XColor',c);
set(h,'YColor',c);

%----------------------------------------------------------------------%
% Callback fired when Location changes. Sets orientation and does layout.
function changedLocation(hProp,eventData,ax)
cbar = eventData.affectedObject;
setOrientation(cbar,ax,get(cbar,'Location'));
legendcolorbarlayout(ax,'layout');

%----------------------------------------------------------------------%
% Sets orientation of the colorbar
function setOrientation(cbar,ax,location)
cbarax = double(cbar);
if ~strcmp(location,'manual')
  img = findobj(cbarax,'Type','image');
  mapsize = getappdata(img,'colormapsize');
  t = getappdata(img,'colormapt');
  switch location(1:4)
   case {'East','West'}
    set(img,'cdata',(1:mapsize)',...
            'ydata',t,...
            'xdata',[0 1]);
    set(cbarax,'ylim',t,'xlim',[0 1],'xtick',[],'ytickmode','auto');
   case {'Nort','Sout'}
    set(img,'cdata',(1:mapsize),...
            'xdata',t,...
            'ydata',[0 1]);
    set(cbarax,'xlim',t,'ylim',[0 1],'ytick',[],'xtickmode','auto');
  end
  % set position according to location
  switch location
   case 'EastOutside'
    set(cbarax,'xtick',[],'yaxislocation','right');
   case 'WestOutside'
    set(cbarax,'xtick',[],'yaxislocation','left');
   case 'SouthOutside'
    set(cbarax,'ytick',[],'xaxislocation','bottom');
   case 'NorthOutside'
    set(cbarax,'ytick',[],'xaxislocation','top');
   case 'North'
    set(cbarax,'ytick',[],'xaxislocation','bottom');
   case 'South'
    set(cbarax,'ytick',[],'xaxislocation','top');
   case 'West'
    set(cbarax,'xtick',[],'yaxislocation','right');
   case 'East'
    set(cbarax,'xtick',[],'yaxislocation','left');
  end
end

%----------------------------------------------------------------------%
% Callback fired when Units change Pre and Post to enable/disable
% position listeners
function changedUnits(hProp,eventData,h,state)
list = h.PropertyListeners;
set(list,'enable',state)

%----------------------------------------------------------------------%
% Callback fired when Position or OuterPosition changes. Enters
% manual positioning mode so that auto-layout doesn't move the object.
function changedPos(hProp,eventData,h,prop)
if strcmp(get(h,'ActivePositionProperty'),prop) && ...
      isempty(getappdata(h.Axes,'inLayout'))
  set(h,'Location','manual')
end

%----------------------------------------------------------------------%
% Callback fired on ObjectBeingDeleted. Updates toolbar toggle
% does layouts of peer axis.
function colorbarDeleted(hProp,eventData,h)

uic = get(h,'UIContextMenu');
if ishandle(uic)
  delete(uic);
end
if ishandle(double(h)) && ...
      ishandle(get(double(h),'parent')) && ...
      ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
  methods(h,'update_toggle_and_menuitem');
  legendcolorbarlayout(double(h.Axes),'layout')
end

%----------------------------------------------------------------------%
% Create child image and set up initial properties
function initialize_colorbar_properties(fig,ax,cbar,position)

cbarax = double(cbar);

% Determine color limits by context.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.
ch = get(get_current_data_axes(fig,ax),'children');
hasimage = 0; t = [];
cdatamapping = 'direct';
mapsize = size(colormap(ax),1);
for i=1:length(ch)
  typ = get(ch(i),'type');
  if strcmp(typ,'image'),
    hasimage = 1;
    cdatamapping = get(ch(i), 'CDataMapping');
  elseif strcmp(typ,'hggroup') && isprop(ch(i),'CDataMapping')
    % charting objects set their own cdata mapping mode
    cdatamapping = get(handle(ch(i)),'CDataMapping');
  elseif strcmp(typ,'surface') & ...
        strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
    hasimage = 2;
    cdatamapping = get(ch(i), 'CDataMapping');
  elseif strcmp(typ,'patch') | strcmp(typ,'surface')
    cdatamapping = get(ch(i), 'CDataMapping');
  end
end
if ( strcmp(cdatamapping, 'scaled') )
  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = caxis(ax);
  d = (t(2) - t(1))/mapsize;
  t = [t(1)+d/2  t(2)-d/2];
else
  if hasimage,
    t = [1, mapsize];
  else
    t = caxis(ax);
    if all(t == [0 1])
      t = [1.5, mapsize+.5];
    end
  end
end

if strcmpi(cbar.Location,'manual')
  % location here is used to determine orientation
  if isempty(position) || position(4)>position(3)
    location = 'EastOutside';
  else 
    location = 'BottomOutside';
  end
else
  location = cbar.Location;
end

img = image('Parent',double(cbar),...
            'Tag','TMW_COLORBAR',...
            'SelectionHighlight','off',...
            'HitTest','off',...
            'Visible','off',...
            'Interruptible','off');
setappdata(img,'colormapsize',mapsize);
setappdata(img,'colormapt',t);
cbar.Image = handle(img);

set(cbarax,...
'Tickdir','in',...
'Layer','top',...
'Ydir','normal', ...
'Tag','Colorbar',...
'Interruptible','off');

% set the orientation and perform initial layout
setOrientation(cbar,ax,location);

%----------------------------------------------------------------------%
% Given a figure and candidate axes, get an axes that colorbar can
% attach to.
function h = get_current_data_axes(hfig, haxes)
h = datachildren(hfig);
if isempty(h) | any(h == haxes)
    h = haxes;
else
    h = h(1);
end

function resetCurrentAxes(hSrc, evdata)
dh = double(hSrc);
fig = ancestor(dh,'figure');
if get(fig,'CurrentAxes') == dh
  set(fig,'CurrentAxes',double(get(hSrc,'Axes')));
end
