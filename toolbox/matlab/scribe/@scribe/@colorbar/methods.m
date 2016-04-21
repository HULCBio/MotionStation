function val = methods(this,fcn,varargin)
% METHODS - methods for colorbar class

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $  $  $

val = [];

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  val = feval(args{:});
end

%----------------------------------------------------------------%
% Extract relevant info for constructing a new colorbar after deserializing
function val=postdeserialize(h)

val.location = h.Location;
val.position = h.Position;
val.ax = h.Axes;
val.cbar = h;

%----------------------------------------------------------------%
function deletecolorbars(cbar)

cbars = find_colorbars(double(cbar.Axes),'any');
if ~isempty(cbars)
    for k=1:length(cbars)
        h = handle(cbars(k));
        if ishandle(double(h)) && ...
                ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
                ishandle(get(double(h),'parent')) && ...
                ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
            h.methods('delete');
        end
    end
end

%----------------------------------------------------------------%
% ButtonUp in Plotedit mode. Check for interactive edit mode.
function handled = bup(h,point)

handled = true;

% if in plotedit mode turn off custom button up
b = hggetbehavior(double(h),'Plotedit');
set(b,'ButtonUpFcn',[]);
set(b,'MouseMotionFcn',[]);

%----------------------------------------------------------------%
% ButtonDown in Plotedit mode. Check for interactive edit mode.
function handled = bdown(h,pt)

handled = false;
fig = ancestor(h,'figure');
if strcmpi(h.Editing,'on')

  % if in plotedit mode turn on custom event handlers
  b = hggetbehavior(double(h),'Plotedit');
  set(b,'ButtonUpFcn',@bup);
  set(b,'MouseMotionFcn',@move_colormap);

  h.ColormapMoveInitialMap = get(fig,'Colormap');
  handled = true;
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  scribeax.CurrentShape = h;
end
if get(fig,'CurrentAxes') == double(h)
  set(fig,'CurrentAxes',double(h.Axes));
end

%----------------------------------------------------------------%
% Return the cursor to use if the mouse is over this object. Used
% in plotedit mode and when the colorbar is in interactive edit mode.
function over=mouseover(h,point)

over=0; % not over object
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
cbpos = h.Position;
inrect =  point(1) > cbpos(1) && point(1) < cbpos(1)+cbpos(3) && ...
      point(2) > cbpos(2) && point(2) < cbpos(2)+cbpos(4);

if isempty(scribeax) || strcmp('off',scribeax.InteractiveCreateMode)
  if strcmpi(h.Editing,'on')
    if inrect>0
      switch h.Location
       case {'East','West','EastOutside','WestOutside'}
        over = 'heditbar';
       case 'manual'
        if cbpos(3)>cbpos(4) % horizontal
          over = 'veditbar';
        else
          over = 'heditbar';
        end
       otherwise
        over = 'veditbar';
      end
    end
  end
end

%----------------------------------------------------------------%
% Compute and set shifted colormap when in interactive edit mode.
function handled = move_colormap(h,pt)

handled = true;
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

map0 = h.ColormapMoveInitialMap;
mapsiz = length(map0);
pt0 = scribeax.NClickPoint;
cbpos = h.Position;

switch h.Location
 case {'East','West','EastOutside','WestOutside'}
  mapindstart = ceil(mapsiz*(pt0(2) - cbpos(2))/cbpos(4));
  mapindsmove = ceil(mapsiz*(pt(2) - pt0(2))/cbpos(4));
 case 'manual'
  if cbpos(3)>cbpos(4) % horizontal
    mapindstart = ceil(mapsiz*(pt0(1) - cbpos(1))/cbpos(3));
    mapindsmove = ceil(mapsiz*(pt(1) - pt0(1))/cbpos(3));
    
  else
    mapindstart = ceil(mapsiz*(pt0(2) - cbpos(2))/cbpos(4));
    mapindsmove = ceil(mapsiz*(pt(2) - pt0(2))/cbpos(4));
  end
  
 otherwise
  mapindstart = ceil(mapsiz*(pt0(1) - cbpos(1))/cbpos(3));
  mapindsmove = ceil(mapsiz*(pt(1) - pt0(1))/cbpos(3));
end

% calculate new colormap
newmap = map0;

if mapindsmove>0
  stretchind = mapindstart+mapindsmove;    
  stretchind = min(stretchind,mapsiz);
  stretchfx = stretchind/mapindstart;
  ixinc = 1/stretchfx;
  ix = 1;
  for k=1:stretchind
    ia = min(mapsiz,floor(ix));
    if ia<mapsiz
      ib = ia+1;
      ifrx = ix - ia;
      newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
    else
      newmap(k,:) = map0(ia,:);
    end
    ix = ix + ixinc;
  end
  % avoid div by 0
  squeezefx = max(1,(mapsiz - stretchind))/(mapsiz - mapindstart);
  ixinc = 1/squeezefx;
  ix = mapindstart;
  for k=stretchind:mapsiz
    ia = min(mapsiz,floor(ix));
    if ia<mapsiz
      ib = ia+1;
      ifrx = ix - ia;
      newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
    else
      newmap(k,:) = map0(ia,:);
    end
    ix = ix + ixinc;
  end
else
  stretchind = mapindstart+mapindsmove;
  stretchind = max(stretchind,1);
  stretchfx = stretchind/mapindstart;
  ixinc = 1/stretchfx;
  ix = 1;
  for k=1:stretchind
    ia = min(mapsiz,floor(ix));
    if ia<mapsiz
      ib = ia+1;
      ifrx = ix - ia;
      newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
    else
      newmap(k,:) = map0(ia,:);
    end
    ix = ix + ixinc;
  end
  squeezefx = (mapsiz - stretchind)/(mapsiz - mapindstart);
  ixinc = 1/squeezefx;
  ix = mapindstart;
  for k=stretchind:mapsiz
    ia = min(mapsiz,floor(ix));
    if ia<mapsiz
      ib = ia+1;
      ifrx = ix - ia;
      newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
    else
      newmap(k,:) = map0(ia,:);
    end
    ix = ix + ixinc;
  end
end

% set it
set(fig,'Colormap',newmap);


%----------------------------------------------------------------%
function calculate_colormap(h)

% fig = double(h.Figure);
% scribeax = h.ScribeAxes;
% 
% map0 = h.BaseColormap;
% 
% for k=1:maplength
%     frx = k/mapsiz;
%     % find lower node
%     for n=1:length(h.CmapNodeFrx)
%         if frx > h.CmapNodeFrx(n)
%             lowernode = n;
%         end
%     end  
%     % find upper node
%     for n=length(h.CmapNodeFrx):1
%         if frx < h.CmapNodeFrx(n)
%             uppernode = n;
%         end
%     end
% set(fig,'Colormap',newmap);

%----------------------------------------------------------------%
function updatefonts(h)

ax = double(h.Axes);
cbars = find_colorbars(ax,'any');
for k=1:length(cbars)
    cax = double(cbars(k));
    set(cax,'fontname',get(ax,'fontname'));
    set(cax,'fontangle',get(ax,'fontangle'));
    set(cax,'fontsize',get(ax,'fontsize'));
    set(cax,'fontweight',get(ax,'fontweight'));
end

%----------------------------------------------------------------------%
function hc = find_colorbars(ha,location)

% find colorbars with plotaxes ha, and location (which may be
% 'any', or one of the standard colorbar location).

fig = get(ha,'parent');
ax = findobj(fig,'type','axes');
hc=[];
k=1;
% vectorize
for k=1:length(ax)
  if iscolorbar(ax(k))
    hax = handle(ax(k));
    if isequal(double(hax.Axes),ha)
      if isequal(location,'any')
        hc(end+1)=ax(k);
      elseif strcmp(location,hax.Location)
        hc(end+1)=ax(k);
      end
    end
  end
end

%----------------------------------------------------------------------%
function tf=iscolorbar(ax)

if length(ax) ~= 1 || ~ishandle(ax) 
    tf=false;
else
    tf=isa(handle(ax),'scribe.colorbar');
end

%----------------------------------------------------------------------%
function startlisteners(h)

% add listeners to peer axes
hax = h.Axes;
ax = double(hax);
if ~isprop(hax,'ScribeColorbarListeners')
    l = schema.prop(hax,'ScribeColorbarListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
end
cls = classhandle(hax);
lis.color = handle.listener(hax, cls.findprop('Color'),...
    'PropertyPostSet', {@PeerAxesChangedColor,h});
lis.fontname = handle.listener(hax, cls.findprop('FontName'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontsize = handle.listener(hax, cls.findprop('FontSize'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontweight = handle.listener(hax, cls.findprop('FontWeight'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontangle = handle.listener(hax, cls.findprop('FontAngle'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.deleted = handle.listener(hax, 'ObjectBeingDestroyed', {@PeerAxesDeleted,h});
h.DeleteProxy = handle(text('parent',hax,...
                            'visible','off', ...
                            'tag','LegendDeleteProxy',...
                            'handlevisibility','off'));
lis.proxydeleted = handle.listener(h.DeleteProxy, 'ObjectBeingDestroyed', {@PeerAxesCleared,h});
set(hax,'ScribeColorbarListeners',lis);

% add listeners to figure
fig = ancestor(h,'figure');
hfig = handle(fig);
if ~isprop(hfig,'ScribeColorbarListeners')
    l = schema.prop(hfig,'ScribeColorbarListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
end
cls = classhandle(hfig);
lis.color = handle.listener(hfig, cls.findprop('Color'),...
    'PropertyPostSet', {@FigureChangedColor,h});
set(hfig,'ScribeColorbarListeners',lis);

%----------------------------------------------------------------%
% Figure listener callbacks
%----------------------------------------------------------------%

%----------------------------------------------------------------%
function FigureChangedColor(hProp,eventData,h)

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
   h.methods('auto_adjust_colors');
end

%----------------------------------------------------------------%
% Peer axes listener callbacks
%----------------------------------------------------------------%
function PeerAxesChangedFontProperties(hProp,eventData,h)

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('updatefonts');
    legendcolorbarlayout(h.Axes,'layout');
end

%----------------------------------------------------------------%
function PeerAxesChangedColor(hProp,eventData,h)

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('auto_adjust_colors');
end

%----------------------------------------------------------------%
function PeerAxesDeleted(hProp,eventData,h)

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('deletecolorbars');
end

%----------------------------------------------------------------%
function PeerAxesCleared(hProp,eventData,h)

PeerAxesDeleted(hProp,eventData,h);

%----------------------------------------------------------------%
function toggle_editmode(h)

cbarax = double(h);
fig = ancestor(h,'figure');
uic = get(cbarax,'UIContextMenu');
if ~isempty(uic)
    emodemenu = findall(uic,'type','UIMenu','Label','Interactive Colormap Shift');
    if ~isempty(emodemenu)
        state = get(emodemenu,'checked');
        if strcmpi(state,'off')
            set(emodemenu,'checked','on');
            plotedit(fig,'on');
            h.Editing = 'on';
            set(cbarax,'linewidth',1);
        else
            set(emodemenu,'checked','off');
            h.Editing = 'off';
            set(cbarax,'linewidth',.5);
        end
    end
end

%----------------------------------------------------------------%
function toggle_editmode_cb(hSrc,evdata,h)

toggle_editmode(h);

%----------------------------------------------------------------%
function set_standard_colormap(h,name)

fig = ancestor(h,'figure');
map = get(fig,'Colormap');
mapsiz = size(map);
map = feval(name,mapsiz(1));
h.BaseColormap = map;
calculate_colormap(h);

set(fig,'colormap',map);

%----------------------------------------------------------------%
function set_standard_colormap_cb(hSrc,evdata,h,name)

set_standard_colormap(h,name);

%---------------------------------------------------------%
function auto_adjust_colors(h)

lpos = h.Position;
lcenter = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)/2];
u = get(h.Axes,'Units');
if ~strcmpi(u,'normalized')
    set(h.Axes,'Units','normalized');
end
apos = get(h.Axes,'Position');
if ~strcmpi(u,'normalized')
    set(h.Axes,'Units',u);
end
fig = ancestor(h,'figure');
fcolor = get(fig,'Color');
acolor = get(h.Axes,'Color');

if lcenter(1)>apos(1) && lcenter(1)<apos(1)+apos(3) && ...
    lcenter(2)>apos(2) && lcenter(2)<apos(2)+apos(4)
    c=acolor;
    if ischar(c)
        c=fcolor;
    end
else
    c=fcolor;
end

if ~ischar(c) && sum(c(:))<1.5
    set(h,'xcolor','w','ycolor','w');
else
    set(h,'xcolor','k','ycolor','k');
end

%---------------------------------------------------------%
% Update the toolbar and menu items. This should probably be
% moved to the toolbar code.
function update_toggle_and_menuitem(h)

fig = ancestor(h,'figure');
cbars = find(handle(fig),'-isa','scribe.colorbar');
cax = get(fig,'CurrentAxes');
if isa(handle(cax),'scribe.legend') || isa(handle(cax),'scribe.colorbar')
    hlc = handle(cax);
    cax = double(hlc.Axes);
end
cbaron=false;
for k=1:length(cbars)
    cbarh = handle(cbars(k));
    if isequal(double(cbarh.Axes),cax) && ...
        ~strcmpi(get(cbarh,'BeingDeleted'),'on')
        cbaron=true;
    end
end
cbtogg = uigettoolbar(fig,'Annotation.InsertColorbar');
cbmenu = findall(fig,'Tag','figMenuInsertColorbar');

if cbaron
    if ~isempty(cbtogg)
        set(cbtogg,'state','on');
    end
    if ~isempty(cbmenu)
        set(cbmenu,'checked','on');
    end
else
    if ~isempty(cbtogg)
        set(cbtogg,'state','off');
    end
    if ~isempty(cbmenu)
        set(cbmenu,'checked','off');
    end
end

%-------------------------------------------------------------------%
%                Colorbar Context Menu
%-------------------------------------------------------------------%

%--------------------------------------------------------------------%
function set_contextmenu(h,onoff)

fig = ancestor(h,'figure');
maplabels={'cool','gray','hot','hsv','jet(default)'};
mapfunctions={'cool','gray','hot','hsv','jet'};
uic = get(h,'UIContextMenu');
if isempty(uic)
  uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',{@update_contextmenu_cb,h});
  plotedit({'add_general_action_menu',uic,'off','Delete',{@delete_self_cb,h}});
  % location
  plotedit({'create_enumstrprop_menu',h,'Location',uic,'Location','on',...
                          {'Outside North','Outside South','Outside West','Outside East','West','East'},...
                          {'NorthOutside','SouthOutside','WestOutside','EastOutside','West','East'}});
  % standard colormaps
  stdmaps=uimenu(uic,'HandleVisibility','off','Label','Standard Colormaps','Separator','on');
  for k=1:length(maplabels)
    uimenu(stdmaps,'HandleVisibility','off','Label', maplabels{k}, ...
           'Callback', {@set_standard_colormap_cb, h, mapfunctions{k}});
  end
  % editmode
  uimenu(uic,'HandleVisibility','off','Label','Interactive Colormap Shift',...
         'Separator','off','Callback',{@toggle_editmode_cb,h});
  % colormap editor
  uimenu(uic,'HandleVisibility','off','Label','Launch Colormap Editor',...
         'Separator','off','Callback',@edit_colormap_cb);
  % properties, mcode
  plotedit({'add_propsandmcode_menus',uic,h});
  % set
  set(h,'uicontextmenu',uic);
end

%--------------------------------------------------------------------%
function edit_colormap_cb(hSrc,evdata)
colormapeditor;

%--------------------------------------------------------------------%
function delete_self_cb(hSrc,evdata,h)
delete(h);

%-------------------------------------------------------------------%
function update_contextmenu(h,onoff)

mapnames={'cool','gray','hot','hsv','jet'};
maplabels={'cool','gray','hot','hsv','jet(default)'};
uic = get(h,'UIContextMenu');
if ~isempty(uic)
  % check correct location item
  plotedit({'update_enumstrprop_menu_checked',h,'Location',uic,'Location',...
                                  {'Top','Bottom','Left','Right','Inside Left','Inside Right'},...
                                  {'top','bottom','left','right','ileft','iright'}});
  % update standard colormaps
  m = findall(uic,'Type','uimenu','Label','Standard Colormaps');
  if ~isempty(m)
    mitems = allchild(m);
    if ~isempty(mitems)
      set(mitems,'Checked','off');
      fig = ancestor(h,'figure');
      cmap = get(fig,'Colormap');
      maplength=length(cmap);
      k=1; found=false;
      while k<length(maplabels) && ~found
        % create test map of type maplabels{k} and length
        % maplength.
        tmap = feval(mapnames{k},maplength);
        if isequal(cmap,tmap)
          % if test map same as figure map, check item.
          found=true;
          mitem = findall(m,'Label',maplabels{k});
          set(mitem,'Checked','on');
        end
        k=k+1;
      end
    end
  end
end

%-------------------------------------------------------------------%
function update_contextmenu_cb(hSrc,evdata,varargin)
update_contextmenu(varargin{:})

%--------------------------------------------------------%
% Helper function to get a function handle to a subfunction
function out=getfunhan(h,str,varargin)

if strcmp(str,'-noobj')
  str = varargin{1};
  if nargin == 3
    out = str2func(str);
  else
    out = {str2func(str),varargin{2:end}};
  end
else
  out = {str2func(str),h,varargin{:}};
end

