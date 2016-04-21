function h=legend(varargin)
%LEGEND creates the scribe legend object
%  H=SCRIBE.LEGEND creates a scribe legend instance
%
%  See also PLOTEDIT

%   Copyright 1984-2004 The MathWorks, Inc.

if (nargin == 0) || ischar(varargin{1})
  hasConvenienceArgs = false;
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
  position = [];
  children = [];
else
  hasConvenienceArgs = true;
  ax=varargin{1};
  fig = ancestor(ax,'figure');
  orient=varargin{2};
  location=varargin{3};
  position=varargin{4};
  children=varargin{5};
  listen=varargin{6};
  strings=varargin{7};
  varargin(1:7) = [];
end
par = get(ax,'Parent');
% be sure nextplot is 'add'
oldNextPlot = get(fig,'NextPlot');
if strcmp(oldNextPlot,'replacechildren') | strcmp(oldNextPlot,'replace')
    set(fig,'NextPlot','add');
end
% start not visible so resizing etc. can't be seen.
h = scribe.legend('Parent',par,'Tag','legend','Visible','off', ...
                  'Units','normalized','Interruptible','off', ...
                  'LooseInset',[0 0 0 0]);
b = hggetbehavior(double(h),'Pan');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Zoom');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Rotate3D');
set(b,'Enable',false);
b = hggetbehavior(double(h),'DataCursor');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Plotedit');
set(b,'KeepContextMenu',true);
set(b,'AllowInteriorMove',true);
set(b,'ButtonUpFcn',methods(h,'getfunhan','-noobj','ploteditbup'));

if ~isappdata(0,'BusyDeserializing')

  if hasConvenienceArgs
    % set legendinfochildren on if children are legendinfo objects
    if isa(children(1),'scribe.legendinfo')
      h.LegendInfoChildren = 'on';
    end
    h.Plotchildren = children;
    if listen
      h.PlotChildListen = 'on';
    else
      h.PlotChildListen = 'off';
    end
    h.Orientation = orient;
    h.Location = location;
    h.String = strings;
  end
  h.Axes = ax;
  % font properties from axes
  h.FontName = get(ax,'fontname');
  h.FontAngle = get(ax,'fontangle');
  h.FontSize = get(ax,'fontsize');
  h.FontWeight = get(ax,'fontweight');
  h.Units = 'normalized';
  h.Selected = 'off';
  if strcmp(get(ax,'color'),'none')
    h.Color = get(fig,'color');
  else
    h.Color = get(ax,'color');
  end

% prevent addition of title, xlabel and ylabel
  setappdata(double(h),'MWBYPASS_title',{graph2dhelper('noop')});
  setappdata(double(h),'MWBYPASS_xlabel',{graph2dhelper('noop')});
  setappdata(double(h),'MWBYPASS_ylabel',{graph2dhelper('noop')});
  setappdata(double(h),'NonDataObject',[]);
  setappdata(double(h),'PostDeserializeFcn',graph2dhelper('legendpostdeserialize'));

  set(double(h),'Tag','legend');
  set(double(h),...
      'Units','normalized',...
      'Box','on',...
      'DrawMode', 'fast',...
      'NextPlot','add',...
      'XTick',[-1],...
      'YTick',[-1],...
      'XTickLabel','',...
      'YTickLabel','',...
      'XLim',[0 1],...
      'YLim',[0 1], ...
      'Clipping','on',...
      'Color',h.Color,...
      'View',[0 90],...
      'CLim',get(ax,'CLim'),...
      'CLimMode',get(ax,'CLimMode'));
  
  if ~isempty(position) && length(position)==4
    set(double(h),'Position',position);
  end

  set(double(h),'ButtonDownFcn',methods(h,'getfunhan','bdowncb'));

  set(fig,'NextPlot',oldNextPlot);
  if ~isempty(children)
    create_legend_items(h,children);
  end
  
  % SET USER DATA
  methods(h,'update_userdata');

  %set up listeners-----------------------------------------
  l= handle.listener(h,h.findprop('Position'),...
                     'PropertyPostSet',{@changedPos,h,'position'});  
  l(end+1)= handle.listener(h,h.findprop('OuterPosition'),...
                            'PropertyPostSet',{@changedPos,h,'outerposition'});
  l(end+1)= handle.listener(h,h.findprop('Units'),...
                            'PropertyPretSet',{@changedUnits,h,'off'});
  l(end+1)= handle.listener(h,h.findprop('Units'),...
                            'PropertyPosttSet',{@changedUnits,h,'on'});
  l(end+1)= handle.listener(h,h.findprop('Selected'),...
                            'PropertyPostSet',@changedSelected);
  l(end+1)= handle.listener(h,h.findprop('Location'),...
                            'PropertyPostSet',{@changedLocation,ax});
  l(end+1)= handle.listener(h,h.findprop('Orientation'),...
                            'PropertyPostSet',{@changedOrientation,ax});
  l(end+1)= handle.listener(h,h.findprop('EdgeColor'),...
                            'PropertyPostSet',@changedEdgeColor);
  l(end+1)= handle.listener(h,h.findprop('TextColor'),...
                            'PropertyPostSet',@changedTextColor);
  l(end+1)= handle.listener(h,h.findprop('Interpreter'),...
                            'PropertyPostSet',@changedFontProperties);
  l(end+1)= handle.listener(h,h.findprop('Box'),...
                            'PropertyPostSet',@changedBox);
  l(end+1)= handle.listener(h,h.findprop('String'),...
                            'PropertyPostSet',@changedString);
  l(end+1)= handle.listener(h,h.findprop('Visible'),...
                            'PropertyPostSet',@changedVisibility);
  l(end+1)= handle.listener(h,h.findprop('FontName'),...
                            'PropertyPostSet',@changedFontProperties);
  l(end+1)= handle.listener(h,h.findprop('FontSize'),...
                            'PropertyPostSet',@changedFontProperties);
  l(end+1)= handle.listener(h,h.findprop('FontWeight'),...
                            'PropertyPostSet',@changedFontProperties);
  l(end+1)= handle.listener(h,h.findprop('FontAngle'),...
                            'PropertyPostSet',@changedFontProperties);
  l(end+1)= handle.listener(h,'LegendInfoChanged',@changedLegendInfo);
  h.PropertyListeners = l;
  l = handle.listener(h,'ObjectBeingDestroyed',{@legendDeleted,h});
  h.DeleteListener = l;
  
  set(double(h),'visible','on');
  set(fig,'currentaxes',ax);
  
  % set other properties passed in varargin
  set(h,varargin{:});

  % add listeners to figure
  if ~isprop(handle(fig),'ScribeLegendListeners')
    l = schema.prop(handle(fig),'ScribeLegendListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
  end
  cls = classhandle(handle(fig));
  flis.currentaxes = handle.listener(handle(fig), cls.findprop('CurrentAxes'),...
                                     'PropertyPostSet', {@FigureChangedCurrentAxes,h});
  set(handle(fig),'ScribeLegendListeners',flis);
  
  % add listeners to plotaxes
  hax = h.Axes;
  ax = double(hax);
  if ~isprop(hax,'ScribeLegendListeners')
    l = schema.prop(hax,'ScribeLegendListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
  end
  cls = classhandle(hax);
  lis.fontname = handle.listener(hax, cls.findprop('FontName'),...
                                 'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
  lis.fontsize = handle.listener(hax, cls.findprop('FontSize'),...
                                 'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
  lis.fontweight = handle.listener(hax, cls.findprop('FontWeight'),...
                                   'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
  lis.fontangle = handle.listener(hax, cls.findprop('FontAngle'),...
                                  'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
  lis.deleted = handle.listener(hax, 'ObjectBeingDestroyed', {@PlotAxesDeleted,h});
  if isequal(h.PlotChildListen,'on')
    lis.childadded = handle.listener(hax, 'ObjectChildAdded', {@PlotAxesChildAdded,h});
  end
  existing_proxy = findall(ax,'tag','LegendDeleteProxy');
  if ~isempty(existing_proxy)
    set(existing_proxy,'DeleteFcn','');
    if length(existing_proxy) > 1
      delete(existing_proxy(2:end));
    end
    h.DeleteProxy = handle(existing_proxy(1));
  else
    h.DeleteProxy = handle(text('parent',hax,...
                                'visible','off', ...
                                'tag','LegendDeleteProxy',...
                                'handlevisibility','off'));
  end
  lis.proxydeleted = handle.listener(h.DeleteProxy, 'ObjectBeingDestroyed', {@PlotAxesCleared,h});
  set(hax,'ScribeLegendListeners',lis);
  
  % set legend ready (complete) on.
  h.Ready = 'on';
  
  % add listeners to plotchildren
  if ~isempty(h.Plotchildren) && ~isa(h.Plotchildren(1),'scribe.legendinfo')
    hpch = h.Plotchildren;
    pch = double(hpch);
    for k=1:length(hpch)
      create_plotchild_listeners(h,hpch(k),pch(k))
    end
    methods(h,'enable_plotchild_listeners','on');
  end

  methods(h,'set_contextmenu','on');

  % set correct state of cbar toggle and menuitem
  methods(h,'update_toggle_and_menuitem');
  legendcolorbarlayout(ax,'on')
  legendcolorbarlayout(ax,'layout')
end
% now make visible
set(h,'Visible','on');

%----------------------------------------------------------------%
% LISTENER CALLBACKS
%----------------------------------------------------------------%


%----------------------------------------------------------------------%
% Callback fired when Units change Pre and Post to enable/disable
% position listeners
function changedUnits(hProp,eventData,h,state)
list = h.PropertyListeners;
set(list,'enable',state)

%----------------------------------------------------------------------%
% Callback fired when Location changes.
function changedLocation(hProp,eventData,ax)
h = eventData.affectedObject;
legendcolorbarlayout(ax,'layout');

%----------------------------------------------------------------------%
% Callback fired when Orientation changes.
function changedOrientation(hProp,eventData,ax)
h = eventData.affectedObject;
methods(h,'layout_legend_items');
methods(h,'update_userdata');
legendcolorbarlayout(ax,'layout');

%----------------------------------------------------------------%
function changedPos(hProp,eventData,h,prop)

if strcmp(get(h,'ActivePositionProperty'),prop) && ...
      isempty(getappdata(h.Axes,'inLayout'))
  set(h,'Location','none')
  methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function changedVisibility(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
  ax = double(h);
  vis = get(ax,'Visible');
  set(ax,'ContentsVisible',vis);
end

%----------------------------------------------------------------%
function changedEdgeColor(hProp,eventData)

h=eventData.affectedObject;
c = get(h,'EdgeColor');
set(h,'XColor',c);
set(h,'YColor',c);

%----------------------------------------------------------------%
function changedTextColor(hProp,eventData)

h=eventData.affectedObject;
set(h.ItemText,'Color',h.TextColor);

%----------------------------------------------------------------%
function changedBox(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if isequal(h.box,'off')
        set(double(h),'visible','off');
        set(double(h.ItemText),'visible','on');
        set(double(h.ItemTokens),'visible','on');
    else
        set(double(h),'visible','on');
    end
    h.ObserveStyle='on';
end

%----------------------------------------------------------------%
% The user changed the legend String property by hand so update
% any DisplayNames and refresh the legend
function changedString(hProp,eventData)

h = eventData.affectedObject;
if ~iscell(h.String) && ischar(h.String)
  h.String = cellstr(h.String);
end
ch = double(h.Plotchildren);
strings = h.String;
if length(strings) > length(ch)
  strings = strings(1:length(ch));
  h.String = strings;
end
newlis = get(h,'ScribePLegendListeners');
for k=1:length(newlis)
  if isfield(newlis{k},'dispname')
    set(newlis{k}.dispname,'enable','off')
  end
end
for k=1:length(strings)
  if ishandle(ch(k)) && isprop(ch(k),'DisplayName')
    set(ch(k),'DisplayName',strings{k});
  end
end
for k=1:length(newlis)
  if isfield(newlis{k},'dispname')
    set(newlis{k}.dispname,'enable','on')
  end
end
methods(h,'update_userdata');
methods(h,'layout_legend_items');
legendcolorbarlayout(h.Axes,'layout');

%----------------------------------------------------------------%
% A legendinfo of an object displayed in the legend changed so
% regenerate legend items
function changedLegendInfo(h,eventData)
% remove old text and token items

hchild = getappdata(double(h.Axes),'legendInfoAffectedObject');
if any(double(h.PlotChildren) == double(hchild))
  methods(h,'layout_legend_items');
  legendcolorbarlayout(double(h.Axes),'layout');
  methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function changedSelected(hProp,eventData)

%----------------------------------------------------------------%
function legendDeleted(hProp,eventData,h)

uic = get(h,'UIContextMenu');
if ishandle(uic)
  delete(uic);
end
if ishandle(double(h)) && ...
      ishandle(get(double(h),'parent')) && ...
      ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
  ax = double(h.Axes);
  if ishandle(ax) && ~strcmpi(get(ax,'beingdeleted'),'on')
    methods(h,'update_toggle_and_menuitem');
    legendcolorbarlayout(double(h.Axes),'layout')
  end
end

%----------------------------------------------------------------%
function changedFontProperties(hProp,eventData)

h=eventData.affectedObject;

% update items for legend
methods(h,'layout_legend_items');
legendcolorbarlayout(double(h.Axes),'layout')
methods(h,'update_userdata');

%----------------------------------------------------------------%
% Figure listener callbacks
%----------------------------------------------------------------%

%----------------------------------------------------------------%
function FigureChangedCurrentAxes(hProp,eventData,h)

if ishandle(double(h)) && ...
    ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
    ishandle(get(double(h),'parent')) && ...
    ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
  methods(h,'update_toggle_and_menuitem');
end


%----------------------------------------------------------------%
% Plot axes listener callbacks
%----------------------------------------------------------------%
function PlotAxesChangedFontProperties(hProp,eventData,h)

ax = double(eventData.affectedObject);
if ishandle(ax) && ishandle(h)
  % font properties from axes
  h.FontName = get(ax,'FontName');
  h.FontAngle = get(ax,'FontAngle');
  h.FontSize = get(ax,'FontSize');
  h.FontWeight = get(ax,'FontWeight');

  % make new items for legend
  methods(h,'layout_legend_items');
  legendcolorbarlayout(double(h.Axes),'layout')
  methods(h,'update_userdata');

end

%----------------------------------------------------------------%
function PlotAxesDeleted(hProp,eventData,h)

if ishandle(h) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(h,'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    delete(h);
end

%----------------------------------------------------------------%
function PlotAxesCleared(hProp,eventData,h)

PlotAxesDeleted(hProp,eventData,h);

%----------------------------------------------------------------%
function PlotAxesChildAdded(hProp,eventData,h)

if ~ishandle(double(h)) || ~isprop(h,'plotchildren')
    return;
end

addchild = true;
newch = double(eventData.child);
newchtype = get(newch,'type');

% note the plot objects are hggroups with LegendInfo appdata and
% that only gets set after the childAdd listener is fired so this
% test will exclude plot objects. Another test is needed here.
if ~graph2dhelper('islegendable',newch)
  return;
end

% check to see if it's a part of an existing scattergroup
% and don't add a new item if it is.
if isempty(h.Plotchildren) || ~all(ishandle(h.Plotchildren))
    % this really shouldn't happen
    typeindex = 1;
    insertindex = 1;   
    ch = [];
else
    ch = double(h.Plotchildren);
    chtypes = get(ch,'type');
    if strcmpi(newchtype,'patch') && isappdata(newch,'scattergroup')
        newscgroup = getappdata(newch,'scattergroup');
        chpatches = ch(strcmpi(chtypes,'patch'));
        k=1;
        while k<=length(chpatches) && addchild
            getappdata(chpatches(k),'scattergroup');
            if isequal(getappdata(chpatches(k),'scattergroup'),newscgroup)
                addchild = false;
            end
            k=k+1;
        end
    end
    if addchild
        % get insert index
        % insert at end of same type items in legend
        sametypeinds = find(strcmpi(newchtype,chtypes));
        typeindex = length(sametypeinds) + 1;
        if ~isempty(sametypeinds)
            insertindex = sametypeinds(end) + 1;
        elseif strcmpi(newchtype,'line')
            insertindex = 1;
        elseif strcmpi(newchtype,'patch')
            lineinds = find(strcmpi('line',chtypes));
            if isempty(lineinds)
                insertindex=1;
            else
                insertindex=lineinds(end) + 1;
            end
        else
            insertindex=length(ch) + 1;
        end
    end
end

if addchild
    % set string for the new item
    newstr = sprintf('%s %d',newchtype,typeindex);
    % create new plotchild and strings lists
    str = h.String;
    if insertindex>length(ch)
        ch(end+1) = newch;
        str{end+1} = newstr;
    else
        ch = [ch(1:insertindex-1);newch;ch(insertindex:length(ch))];
        str = [str(1:insertindex-1);{newstr};str(insertindex:length(str))];
    end
    h.Plotchildren = ch;
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = str;
    set(h.PropertyListeners,'enable','on'); % for string listener
    
    % remove old text and token items
    delete(h.ItemText);
    delete(h.ItemTokens);
    
    create_legend_items(h,ch);
    legendcolorbarlayout(double(h.Axes),'layout');
    % update user data
    methods(h,'update_userdata');

    % add listeners for new plotchild
    create_plotchild_listeners(h,handle(newch),newch);
end

%----------------------------------------------------------------%
% Plot children listeners and callbacks
%----------------------------------------------------------------%
function create_plotchild_listeners(h,hch,ch)

if ~isprop(h,'ScribePLegendListeners')
    l = schema.prop(h,'ScribePLegendListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
    newlis = {};
else
    newlis = get(h,'ScribePLegendListeners');
end
cls = classhandle(hch);
type = get(ch,'type');
switch type
    case 'line'
        lis.color = handle.listener(ch, cls.findprop('Color'), 'PropertyPostSet', {@PlotChildLinePropChanged,h,hch});
    case {'patch','surface'}
        lis.facecolor = handle.listener(ch, cls.findprop('FaceColor'), 'PropertyPostSet', {@PlotChildPatchPropChanged,h,hch});
        lis.edgecolor = handle.listener(ch, cls.findprop('EdgeColor'), 'PropertyPostSet', {@PlotChildPatchPropChanged,h,hch});
end
lis.linestyle = handle.listener(ch, cls.findprop('LineStyle'), 'PropertyPostSet', {@PlotChildAllLinePropChanged,h,hch});
lis.linewidth = handle.listener(ch, cls.findprop('LineWidth'), 'PropertyPostSet', {@PlotChildAllLinePropChanged,h,hch});
lis.marker = handle.listener(ch, cls.findprop('Marker'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,hch});
lis.markersize = handle.listener(ch, cls.findprop('MarkerSize'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,hch});
lis.markeredgecolor = handle.listener(ch, cls.findprop('MarkerEdgeColor'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,hch});
lis.markerfacecolor = handle.listener(ch, cls.findprop('MarkerFaceColor'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,hch});
if isprop(hch,'DisplayName')
    lis.dispname = handle.listener(ch, cls.findprop('DisplayName'),'PropertyPostSet',{@PlotChildDispNameChanged,h,hch});  
end
if isequal(h.PlotChildListen,'on')
    lis.deleted = handle.listener(ch, 'ObjectBeingDestroyed', {@PlotChildDeleted,h,hch});
end
newlis{end+1} = lis;
set(h,'ScribePLegendListeners',newlis);


%----------------------------------------------------------------%
function PlotChildLinePropChanged(hProp,eventData,h,hch)

tok = [];
tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linetokenhandle')];
tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle')];
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildPatchPropChanged(hProp,eventData,h,hch)

tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildAllLinePropChanged(hProp,eventData,h,hch)

tok=[];
if strcmpi(get(double(eventData.AffectedObject),'type'),'line')
    tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linetokenhandle')];
    tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle')];
else
    tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
end
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildMarkerPropChanged(hProp,eventData,h,hch)

if strcmpi(get(double(eventData.AffectedObject),'type'),'line')
    tok = getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle');
else
    tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
end
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildDispNameChanged(hProp,eventData,h,hch)

methods(h,'update_legend_items');
legendcolorbarlayout(double(h.Axes),'layout');
methods(h,'update_userdata');

%----------------------------------------------------------------%
function PlotChildDeleted(hProp,eventData,h,hch)

if ~ishandle(double(h)) || ~isprop(h,'plotchildren')
    return;
end

delchild = true;
delch = double(hch);
delchtype = get(delch,'type');
ch = double(h.Plotchildren);

% check to see if it's a part of an existing scattergroup
% and don't delete the item if it is.
if ~isempty(h.Plotchildren)
    chtypes = get(ch,'type');
    if strcmpi(delchtype,'patch') && isappdata(delch,'scattergroup')
        delscgroup = getappdata(delch,'scattergroup');
        chpatches = ch(strcmpi(chtypes,'patch'));
        k=1;
        while k<=length(chpatches) && delchild
            getappdata(chpatches(k),'scattergroup');
            % don't delete if there is another patch with the same
            % scattergroup
            if isequal(getappdata(chpatches(k),'scattergroup'),delscgroup) && ...
                    ~isequal(chpatches(k),delch)
                delchild = false;
            end
            k=k+1;
        end
    end
end

if delchild
    % get delete index
    delindex = find(eq(delch,ch));
    % remove from child and strings lists
    str = h.String;
    if length(ch)==1
        ch = [];
        str = {};
    elseif delindex==1
        ch = [ch(2:length(ch))];
        str = [str(2:length(str))];
    elseif delindex==length(ch)
        ch = [ch(1:length(ch)-1)];
        str = [str(1:length(str)-1)];
    else
        ch = [ch(1:delindex-1);ch(delindex+1:length(ch))];
        str = [str(1:delindex-1);str(delindex+1:length(str))];
    end
    
    h.Plotchildren = ch;
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = str;
    set(h.PropertyListeners,'enable','on'); % for string listener
    
    % remove old text and token items
    delete(h.ItemText);
    delete(h.ItemTokens);
    
    % update legend
    if isempty(ch)
        % if no children, delete legend
        delete(h);
    else
        % make new items for legend
        create_legend_items(h,ch);
        legendcolorbarlayout(double(h.Axes),'layout');
        % update user data
        methods(h,'update_userdata');
    end
end
%----------------------------------------------------------------%
% Local Utilities
%----------------------------------------------------------------%
function create_legend_items(h,children)

% position informaiton (repeated code, consolidate!)
ax = double(h);
fig = ancestor(h,'figure');
fpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),...
                      'points',0);

% construct strings from string cell and counts
strings = h.String;

s = methods(h,'getsizeinfo');
lpos = ones(1,4);
lpos(3:4) = methods(h,'getsize',s);

% initial token and text positions
tokenx = [s.leftspace s.leftspace+s.tokenwidth]/lpos(3);
textx = (s.leftspace+s.tokenwidth+s.tokentotextspace)/lpos(3);
% initial ypos (for text and line items)
ypos = 1 - ((s.topspace+(s.strsizes(1,2)/2))/lpos(4)); % middle of token
% initial tokeny (top and bottom of patch) for patch items
tokeny = ([s.strsizes(1,2)/-2.5 + s.rowspace/2, s.strsizes(1,2)/2.5 - s.rowspace/2]/lpos(4)) + ypos;
% y increment for vertically oriented legends
yinc = (s.rowspace + s.strsizes(:,2))/lpos(4);
% x increment (not including string) for horizontally oriented legends
xinc = (s.tokenwidth + s.tokentotextspace + s.colspace)/lpos(3);

texthandle = zeros(length(children),1);
tokenhandle = [];

for k=1:length(children)
  item = children(k);
  % TEXT OBJECT
  texthandle(k) = text('Parent',double(h),...
                       'Interpreter',h.Interpreter,...
                       'Units','normalized',...
                       'Color',h.TextColor,...
                       'String',strings{k},...
                       'Position',[textx ypos 0],...
                       'VerticalAlignment','middle',...
                       'SelectionHighlight','off',...
                       'Interruptible','off');
  set(texthandle(k),'FontUnits','points',...
                    'FontAngle',h.FontAngle,...
                    'FontWeight',h.FontWeight,...
                    'FontName',h.FontName);
  set(texthandle(k),'FontSize',h.FontSize);
  set(texthandle(k),'ButtonDownFcn',methods(h,'getfunhan','tbdowncb',k)); 
  setappdata(item,'legend_texthandle',texthandle(k));
  % TOKEN (GRAPHIC)
  if isa(item,'scribe.legendinfo')
    li = item;
    tokenhandle(end+1) = hg.hggroup(...
        'Parent',double(h),...
        'HitTest','off',...
        'Tag',strings{k}(:).',...
        'SelectionHighlight','off',...
        'Interruptible','off');
    methods(h,'build_legendinfo_token',tokenhandle(end),li,tokenx,tokeny);
  else
    type=get(item,'type');
    if isappdata(item,'LegendLegendInfo')
      li = getappdata(item,'LegendLegendInfo');
      tokenhandle(end+1) = hg.hggroup(...
          'Parent',double(h),...
          'HitTest','off',...
          'Tag',strings{k}(:).',...
          'SelectionHighlight','off',...
          'Interruptible','off');
      methods(h,'build_legendinfo_token',tokenhandle(end),li,tokenx,tokeny);
    else
      switch type
        % FOR LINE
       case 'line'
        % LINE PART OF LINE
        tokenhandle(end+1) = line('Parent',double(h),...
                                  'Color',get(item,'Color'),...
                                  'LineWidth',get(item,'LineWidth'),...
                                  'LineStyle',get(item,'LineStyle'),...
                                  'Marker','none',...
                                  'XData',tokenx,...
                                  'YData',[ypos ypos],...
                                  'Tag',strings{k}(:).',...
                                  'SelectionHighlight','off',...
                                  'HitTest','off',...
                                  'Interruptible','off');
        setappdata(item,'legend_linetokenhandle',tokenhandle(end));
        % MARKER PART OF LINE
        % line for marker part (having a separate line for the marker
        % allows us to center the marker in the line.
        tokenhandle(end+1) = line('Parent',double(h),...
                                  'Color',get(item,'Color'),...
                                  'LineWidth',get(item,'LineWidth'),...
                                  'LineStyle','none',...
                                  'Marker',get(item,'Marker'),...
                                  'MarkerSize',get(item,'MarkerSize'),...
                                  'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
                                  'MarkerFaceColor',get(item,'MarkerFaceColor'),...
                                  'XData', [(tokenx(1) + tokenx(2))/2],...
                                  'YData', [ypos],...
                                  'HitTest','off',...
                                  'SelectionHighlight','off',...
                                  'Interruptible','off');
        setappdata(item,'legend_linemarkertokenhandle',tokenhandle(end));
        % FOR PATCH
       case {'patch','surface'}
        pyd = get(item,'xdata');
        if length(pyd) == 1
          pxdata = sum(tokenx)/length(tokenx);
          pydata = ypos;
        else
          pxdata = [tokenx(1) tokenx(1) tokenx(2) tokenx(2)];
          pydata = [tokeny(1) tokeny(2) tokeny(2) tokeny(1)];
        end
        [edgecol,facecol] = methods(h,'patchcolors',item);
        [facevertcdata,facevertadata] = methods(h,'patchvdata',item);
        tokenhandle(end+1) = patch('Parent',double(h),...
                                   'FaceColor',facecol,...
                                   'EdgeColor',edgecol,...
                                   'LineWidth',get(item,'LineWidth'),...
                                   'LineStyle',get(item,'LineStyle'),...
                                   'Marker',get(item,'Marker'),...
                                   'MarkerSize',h.FontSize,...
                                   'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
                                   'MarkerFaceColor',get(item,'MarkerFaceColor'),...
                                   'XData', pxdata,...
                                   'YData', pydata,...
                                   'FaceVertexCData',facevertcdata,...
                                   'FaceVertexAlphaData',facevertadata,...
                                   'Tag',strings{k}(:).',...
                                   'SelectionHighlight','off',...
                                   'HitTest','off',...
                                   'Interruptible','off');
        setappdata(item,'legend_patchtokenhandle',tokenhandle(end));
      end
    end
  end
  if k<length(children)
    if strcmpi(h.Orientation,'vertical')
      ypos = ypos - (yinc(k)+yinc(k+1))/2;
      tokeny = tokeny - (yinc(k)+yinc(k+1))/2;
    else
      tokenx = tokenx + xinc + s.strsizes(k,1)/lpos(3);
      textx = textx + xinc + s.strsizes(k,1)/lpos(3);
    end
  end
end
h.ItemText = texthandle;
h.ItemTokens = tokenhandle;
