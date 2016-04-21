function varargout = methods(this,fcn,varargin)
%METHODS Methods for legend class

%   Copyright 1984-2004 The MathWorks, Inc. 

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    varargout{1} = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  [varargout{1:nargout}] = feval(args{:});
end

%----------------------------------------------------------------%
% Extract relevant info for constructing a new legend after deserializing
function val=postdeserialize(h)

val.strings = h.String';
val.loc = h.Location;
fig = ancestor(h,'figure');
val.position = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
                              'points',fig);
val.ax = getappdata(double(h),'PeerAxes');
val.leg = h;
val.plotchildren = getappdata(double(h),'PlotChildren');
val.viewprops = {'Orientation','TextColor','EdgeColor',...
                    'Interpreter','Box','Visible','Color'};
val.viewvals = get(h,val.viewprops);
val.units = get(h,'Units');

%----------------------------------------------------------------%
% Motion callback for moving a legend. Not called in Plotedit mode.
function bmotion(h)

fig = ancestor(h,'figure');
pt = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],get(fig,'Units'),...
                    'points',fig);
pt = pt(3:4);

% check if a drag has been started, either by moving alot or waiting
startpt = getappdata(double(h),'StartPoint');
if ~isempty(startpt)
  if (any(abs(startpt - pt) > 5)) || ...
        (etime(clock,getappdata(double(h),'StartClock')) > .5)
    rmappdata(double(h),'StartPoint');
  else
    return;
  end
end

oldpt = getappdata(double(h),'LastPoint');
if isempty(oldpt), oldpt = startpt; end

% move position if current point has moved
if ~isequal(pt,oldpt)
  posPts = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
                          'points',fig);
  posPts(1:2) = posPts(1:2) - oldpt + pt;
  newpos = hgconvertunits(fig,posPts,'points',...
                          get(h,'Units'),fig);
  set(double(h),'Position',newpos);
  setappdata(double(h),'LastPoint',pt);
end

%----------------------------------------------------------------%
function bmotioncb(hSrc,evdata,h)
bmotion(h);

%----------------------------------------------------------------%
% ButtonUp callback for legend. Not called in Plotedit mode.
function bup(h)

fig = ancestor(h,'figure');
winfuns = getappdata(double(h),'TempWinFuns');
set(fig,'Pointer',getappdata(double(h),'OldCursor'));
set(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},winfuns);
try
  rmappdata(double(h),'LastPoint');
end

%----------------------------------------------------------------%
function bupcb(hSrc,evdata,h)
bup(h);

%----------------------------------------------------------------%
% ButtonUp for Plotedit mode. Checks for double-click on text.
% We start editing on button up instead of the button down since
% double-clicking starts the property editor and that flushes
% the event queue causing the events to get processed incorrectly.
function handled = ploteditbup(h,pt)

handled = false;
fig = ancestor(h,'figure');
obj = hittest(fig);
if ~isempty(obj) && strcmp(get(obj,'Type'),'text') && ...
      strcmp(get(fig,'SelectionType'),'open')
  n = find(obj == h.ItemText);
  handled = true;
  start_textitem_edit(h,n);
end

%----------------------------------------------------------------%
% ButtonDown for legend. Not called in Plotedit mode.
function bdown(h)

fig = ancestor(h,'figure');
if isappdata(fig,'scribeActive'), return; end

pt = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],get(fig,'Units'),...
                    'points',fig);
pt = pt(3:4);
oldwinfuns = get(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
setappdata(double(h),'TempWinFuns',oldwinfuns);
setappdata(double(h),'StartPoint',pt);
setappdata(double(h),'StartClock',clock);
setappdata(double(h),'OldCursor',get(fig,'Pointer'));
set(fig,'WindowButtonMotionFcn',{@bmotioncb,h});
set(fig,'WindowButtonUpFcn',{@bupcb,h});
set(fig,'Pointer','fleur');

%----------------------------------------------------------------%
function bdowncb(hSrc,evdata,h)
bdown(h)

%----------------------------------------------------------------%
% ButtonDown for legend text objects. Not called in Plotedit mode.
function tbdown(h,n)

fig = ancestor(h,'figure');
seltype = get(fig,'SelectionType');
if strcmpi(seltype,'open')
  start_textitem_edit(h,n);
else
  bdown(h);
end

%----------------------------------------------------------------%
function tbdowncb(hSrc,evdata,h,n)
tbdown(h,n);

%----------------------------------------------------------------%
% Start editing legend text item n.
function start_textitem_edit(h,n)

fig = ancestor(h,'figure');
th = double(h.itemText);
set(th(n),'Edit','on');
setappdata(double(h),'TempWinFuns',get(fig,'WindowButtonDownFcn'));
set(fig,'WindowButtonDownFcn',getfunhan(h,'end_textitem_editcb',n));

%----------------------------------------------------------------%
% Stop editing legend text item n.
function end_textitem_edit(h,n)

fig = ancestor(h,'figure');
th = double(h.itemText);
t = th(n);

if ~isequal(get(fig,'CurrentObject'),t)
  if isempty(h.PlotChildren) || ~isprop(h.PlotChildren(n),'DisplayName')
    strings = h.String;
    strings{n} = get(t,'String');
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = strings;
    set(h.PropertyListeners,'enable','on'); % for string listener
  else
    str = get(t,'String');
    if size(str,1) > 1
      cstr = cellstr(str);
      s = repmat('%s\n',1,length(cstr));
      s(end-1:end) = [];
      str = sprintf(s,cstr{:});
    end
    set(h.PlotChildren(n),'DisplayName',str);
  end
  update_userdata(h);
  update_legend_items(h);
  legendcolorbarlayout(h.Axes,'layout');
  set(fig,'WindowButtonDownFcn',getappdata(double(h),'TempWinFuns'));
end

%----------------------------------------------------------------%
function end_textitem_editcb(hSrc,evdata,h,n)
end_textitem_edit(h,n);

%----------------------------------------------------------------%
% Recompute legend strings and refresh legend layout
function update_legend_items(h)

ch = double(h.Plotchildren);
strings = h.String;
% update strings for display names
for k=1:length(strings)
    if isprop(ch(k),'DisplayName') && ...
            ~isempty(get(ch(k),'DisplayName'))
        dname = get(ch(k),'DisplayName');
        if ~isempty(dname)
          strings{k} = dname;
        end
    end
end
set(h.PropertyListeners,'enable','off'); % for string listener
h.String = strings;
set(h.PropertyListeners,'enable','on'); % for string listener
layout_legend_items(h);

%----------------------------------------------------------------%
% Layout legend contents and refresh the properties of each
% entry to match any plot changes.
function layout_legend_items(h)

ch = double(h.Plotchildren);
strings = h.String;

% position informaiton 
s = getsizeinfo(h);
% legend size
lpos = ones(1,4);
lpos(3:4) = getsize(h,s);
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

texthandle = h.ItemText;
tokenhandle = h.ItemTokens;
tindex = 1;
for k=1:length(ch)
  item = ch(k);
  % TEXT OBJECT
  set(texthandle(k),...
      'Color',h.TextColor,...
      'String',strings{k},...
      'Position',[textx ypos 0],...
      'Interpreter',h.Interpreter,...
      'FontSize',h.FontSize,...
      'FontAngle',h.FontAngle,...
      'FontWeight',h.FontWeight,...
      'FontName',h.FontName);

  if ~ishandle(item), continue; end

  % TOKEN
  if isappdata(item,'LegendLegendInfo')
    li = getappdata(item,'LegendLegendInfo');
    if ishandle(tokenhandle(tindex))
      delete(get(tokenhandle(tindex),'Children'));
    end
    if ~isempty(li)
      build_legendinfo_token(h,tokenhandle(tindex),li,tokenx,tokeny);
    end
    tindex = tindex+1;
  else
    type=get(item,'type');
    switch type
      % FOR LINE
     case 'line'
      % LINE PART OF LINE
      set(tokenhandle(tindex),...
          'Color',get(item,'Color'),...
          'LineWidth',get(item,'LineWidth'),...
          'LineStyle',get(item,'LineStyle'),...
          'Marker','none',...
          'XData',tokenx,...
          'YData',[ypos ypos],...
          'Tag',strings{k}(:).');
      tindex = tindex+1;
      % MARKER PART OF LINE
      % line for marker part (having a separate line for the marker
      % allows us to center the marker in the line.
      set(tokenhandle(tindex),...
          'Color',get(item,'Color'),...
          'LineWidth',get(item,'LineWidth'),...
          'LineStyle','none',...
          'Marker',get(item,'Marker'),...
          'MarkerSize',get(item,'MarkerSize'),...
          'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
          'MarkerFaceColor',get(item,'MarkerFaceColor'),...
          'XData', [(tokenx(1) + tokenx(2))/2],...
          'YData', [ypos]);
      tindex = tindex+1;
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
      [edgecol,facecol] = patchcolors(h,item);
      [facevertcdata,facevertadata] = patchvdata(h,item);
      set(tokenhandle(tindex),...
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
          'Tag',strings{k}(:).');
      tindex = tindex+1;
    end
  end
  if k<length(ch)
    if strcmpi(h.Orientation,'vertical')
      ypos = ypos - (yinc(k)+yinc(k+1))/2;
      tokeny = tokeny - (yinc(k)+yinc(k+1))/2;
    else
      tokenx = tokenx + xinc + s.strsizes(k,1)/lpos(3);
      textx = textx + xinc + s.strsizes(k,1)/lpos(3);
    end
  end
end

%----------------------------------------------------------------%
function build_legendinfo_token(legh,gh,li,tx,ty)
% gh = handle to group object (parent)
% li = legend info handle

% get and build components of li
gcomp = li.GlyphChildren;
for k=1:length(gcomp)
    build_legendinfo_component(gh,gcomp(k),tx,ty);
end

%----------------------------------------------------------------%
function lich=build_legendinfo_component(p,lic,tx,ty)
% p = parent
% lic = legendinfochild

% create the component lich from lic properties (if any)
if isempty(lic.PVPairs)
    lich=feval(lic.ConstructorName,'Parent',double(p));
else
    lich=feval(lic.ConstructorName,'Parent',double(p),lic.PVPairs{:});
end

% adjust x and y data (line, patch)
if isprop(lich,'xdata') && isprop(lich,'ydata')
    x = get(lich,'xdata');
    y = get(lich,'ydata');
    x = tx(1) + diff(tx).*x;
    y = ty(1) + diff(ty).*y;
    set(lich,'xdata',x,'ydata',y);
end

% adjust position (text)
if isprop(lich,'position')
    pos = get(lich,'position');
    pos(1) = tx(1) + diff(tx).*pos(1);
    pos(2) = ty(1) + diff(ty).*pos(2);
    set(lich,'position',pos);
end

if ~isempty(lic.GlyphChildren)
    % get components of the component
    gcomp = lic.GlyphChildren;
    % build those children
    for k=1:length(gcomp)
        build_legendinfo_component(lich,gcomp(k),tx,ty);
    end
end

%----------------------------------------------------------------%
% Update the legend UserData for backwards compatibility
function update_userdata(h)

ud.PlotHandle = double(h.Axes);
ud.legendpos = getnpos(h);
ud.LegendPosition = get(double(h),'position');
ud.LabelHandles = [double(h.ItemText)' double(h.ItemTokens)']';
if ~isa(h.Plotchildren(1),'scribe.legendinfo') 
    ud.handles = double(h.Plotchildren);
else
    % legend with legendinfo specs only require handle handles
    ud.handles = h.Plotchildren;
end
ud.lstrings = h.String';
ud.LegendHandle = double(h);
set(double(h),'userdata',ud);

%----------------------------------------------------------------%
% Return the "numeric" position of a legend
function npos = getnpos(h)

switch h.location
 case 'Best'
  npos = 0;
 case 'NorthWest'
  npos = 2;
 case 'NorthEast'
  npos = 1;
 case 'NorthEastOutside'
  npos = -1;
 case 'SouthWest'
  npos = 3;
 case 'SouthEast'
  npos = 4;
 otherwise
  fig = ancestor(h,'figure');
  npos = hgconvertunits(fig,get(double(h),'Position'),get(h,'Units'),...
                        'points',get(h,'Parent'));
end

%----------------------------------------------------------------%
% Get the layout information for a legend. This includes string
% extents and gap amounts. All sizes are normalized to the figure.
function out = getsizeinfo(h)

fig = ancestor(h,'figure');
fpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),...
                            'points',0);
ax = double(h);
fname = get(ax,'fontname'); fsize = get(ax,'fontsize');
fangl = get(ax,'fontangle'); fwght = get(ax,'fontweight');
interp = get(ax,'Interpreter');
strings = h.String;
% get normalized (to figure/overlay) sizes of all strings
strsizes = ones(length(strings),2);
for k=1:length(strings)
  str = strings{k};
  if isempty(str), str = 'Onj'; end
  strsizes(k,:) = strsize(h,fpos,fname,fsize,fangl,fwght,interp,str);
end
% space sizes in/around legend:

topspace = 2; out.topspace = topspace/fpos(4);
rowspace = 0.5; out.rowspace = rowspace/fpos(4);
botspace = 2; out.botspace = botspace/fpos(4);
leftspace = 6; out.leftspace = leftspace/fpos(3);
rightspace = 3; out.rightspace = rightspace/fpos(3);
tokentotextspace = 3; out.tokentotextspace = tokentotextspace/fpos(3);
colspace = 5; out.colspace = colspace/fpos(3);
out.tokenwidth = h.itemTokenSize(1)/fpos(3);
% spaces between legend and axes
laxspace = 5; out.xlaxspace = laxspace/fpos(3); out.ylaxspace = laxspace/fpos(4);
out.strsizes = strsizes;

%----------------------------------------------------------------%
% Get the width and height of a legend using size info struct s
function lsiz = getsize(h,s)

if nargin == 1, s = getsizeinfo(h); end

% legend size
if strcmpi(h.Orientation,'vertical')
    lsiz = [s.leftspace + s.tokenwidth + s.tokentotextspace + max(s.strsizes(:,1)) + s.rightspace,...
        s.topspace + sum(s.strsizes(:,2)) + (length(h.String) - 1)*s.rowspace + s.botspace];
else
    lsiz = [s.leftspace + (s.tokenwidth*length(h.String)) + (s.tokentotextspace*length(h.String)) + ...
        (length(h.String) - 1)*s.colspace + sum(s.strsizes(:,1)) + s.rightspace,...
        s.topspace + max(s.strsizes(:,2)) + s.rowspace + s.botspace];
end

%----------------------------------------------------------------%
% Get the best location for legend to minimize data overlap
function pos = get_best_location(h)
pos(3:4) = getsize(h);
pos(1:2) = lscan(double(h.Axes),pos(3),pos(4),0,1);

%----------------------------------------------------------------%
% Scan for good legend location.
function Pos = lscan(ha,wdt,hgt,tol,stickytol)

hau = get(ha,'units');
% Calculate tile size
cap = hgconvertunits(ancestor(ha,'figure'),...
                     get(ha,'Position'),get(ha,'Units'),...
                     'normalized',get(ha,'Parent'));
xlim=get(ha,'Xlim');
ylim=get(ha,'Ylim');
H=ylim(2)-ylim(1);
W=xlim(2)-xlim(1);

dh = 0.03*H;
dw = 0.03*W;
Hgt = hgt*H/cap(4);
Wdt = wdt*W/cap(3);
Thgt = H/max(1,floor(H/(Hgt+dh)));
Twdt = W/max(1,floor(W/(Wdt+dw)));
dh = (Thgt - Hgt)/2;
dw = (Twdt - Wdt)/2;

% Get data, points and text
Kids=get(ha,'children');
Xdata=[];Ydata=[];
for i=1:length(Kids),
    type = get(Kids(i),'type');
    if strcmp(type,'line')
        xk = get(Kids(i),'Xdata');
        yk = get(Kids(i),'Ydata');
        eithernan = isnan(xk) | isnan(yk);
        xk(eithernan) = [];
        yk(eithernan) = [];
        nx = length(xk);
        ny = length(yk);
        if nx < 100 && nx > 1 && ny < 100 && ny > 1
            xk = interp1(xk,linspace(1,nx,200));
            yk = interp1(yk,linspace(1,ny,200));
        end
        Xdata=[Xdata,xk];
        Ydata=[Ydata,yk];
    elseif strcmp(type,'patch') | strcmp(type,'surface')
        xk = get(Kids(i),'Xdata');
        yk = get(Kids(i),'Ydata');
        Xdata=[Xdata,xk(:)'];
        Ydata=[Ydata,yk(:)'];
    elseif strcmp(get(Kids(i),'type'),'text'),
        tmpunits = get(Kids(i),'units');
        set(Kids(i),'units','data')
        tmp=get(Kids(i),'Position');
        ext=get(Kids(i),'Extent');
        set(Kids(i),'units',tmpunits);
        Xdata=[Xdata,[tmp(1) tmp(1)+ext(3)]];
        Ydata=[Ydata,[tmp(2) tmp(2)+ext(4)]];
    end
end
% make sure xdata and ydata have same length
if ~isequal(length(Xdata),length(Ydata))
    xydlength = min(length(Xdata),length(Ydata));
    Xdata = Xdata(1:xydlength);
    Ydata = Ydata(1:xydlength);
end
% xdata and ydata must have same dimensions
in = finite(Xdata) & finite(Ydata);
Xdata = Xdata(in);
Ydata = Ydata(in);

% Determine # of data points under each "tile"
xp = (0:Twdt:W-Twdt) + xlim(1);
yp = (0:Thgt:H-Thgt) + ylim(1);
wtol = Twdt / 100;
htol = Thgt / 100;
for j=1:length(yp)
    for i=1:length(xp)
        pop(j,i) = sum(sum((Xdata > xp(i)-wtol) & (Xdata < xp(i)+Twdt+wtol) & ...
            (Ydata > yp(j)-htol) & (Ydata < yp(j)+Thgt+htol)));    
    end
end

if all(pop(:) == 0), pop(1) = 1; end

% Cover up fewest points.  After this while loop, pop will
% be lowest furthest away from the data
while any(pop(:) == 0)
    newpop = filter2(ones(3),pop);
    if all(newpop(:) ~= 0)
        break;
    end
    pop = newpop;
end

[j,i] = find(pop == min(pop(:)));
xp =  xp - xlim(1) + dw;
yp =  yp - ylim(1) + dh;
Pos = [cap(1)+xp(i(end))*cap(3)/W
    cap(2)+yp(j(end))*cap(4)/H];

%----------------------------------------------------------------%
% return size of string normalized to fpos (which should be in points)
function size=strsize(ax,fpos,fontname,fontsize,fontangle,fontweight,interp,str)

ax = double(ax);
t = getappdata(ax,'LegendTempText');
if isempty(t)
  t=text('Parent',ax,...
         'Units','points',...
         'Visible','off',...
         'HandleVisibility','off',...
         'Editing','off',...
         'Margin', 0.01,...
         'Tag','temphackytext');
  setappdata(ax,'LegendTempText',t);
end
set(t,'FontUnits','points');
oldwarn = warning('off');
set(t,'FontSize',fontsize,...
      'Interpreter',interp,...
      'FontAngle',fontangle,...
      'FontWeight',fontweight,...
      'String',str, ...
      'FontName',fontname);

ext = get(t,'extent');
size = ext(3:4)./fpos(3:4);
warning(oldwarn);

%----------------------------------------------------------------%
% Removes all plot listeners
function clear_plotchild_listeners(h)

hch = h.Plotchildren;
for k=1:length(hch)
  if ishandle(hch(k)) && ...
        (~isprop(hch(k),'BeingDeleted') || ...
         ~strcmpi(get(hch(k),'BeingDeleted'),'on'))
    if isprop(hch(k),'ScribeLegendListeners')
      lis = get(hch(k),'ScribeLegendListeners');
      set(hch(k),'ScribeLegendListeners',[]);
    end
  end
end

%----------------------------------------------------------------%
% Turn on/off plot listeners
function enable_plotchild_listeners(h,onoff)

if strcmpi(h.Ready,'on')
  hch = h.Plotchildren;
  for k=1:length(hch)
    if ishandle(hch(k)) && ...
          (~isprop(hch(k),'BeingDeleted') || ...
           ~strcmpi(get(hch(k),'BeingDeleted'),'on'))
      if isprop(hch(k),'ScribeLegendListeners')
        lis = get(hch(k),'ScribeLegendListeners');
        if ~isempty(lis)
          type = get(double(hch(k)),'type');
          switch type
           case 'line'
            lis.Color.enable=onoff;
           case {'patch','surface'}
            lis.facecolor.enable=onoff;
            lis.edgecolor.enable=onoff;
          end
          lis.linestyle.enable=onoff;
          lis.linewidth.enable=onoff;
          lis.marker.enable=onoff;
          lis.markersize.enable=onoff;
          lis.markeredgecolor.enable=onoff;
          lis.markerfacecolor.enable=onoff;
          if isfield(lis,'dispname')
            lis.dispname.enable=onoff;
          end
          if isequal(h.PlotChildListen,'on')
            lis.deleted.enable=onoff;
          end
        end
      end
    end
  end
end

%---------------------------------------------------------%
% Update the toolbar and menu items. This should probably be
% moved to the toolbar code.
function update_toggle_and_menuitem(h)

fig = ancestor(h,'figure');
cax = get(fig,'CurrentAxes');
if isa(handle(cax),'scribe.legend') || isa(handle(cax),'scribe.colorbar')
  hlc = handle(cax);
  cax = double(hlc.Axes);
end
leg = find_legend(cax);
if ~isempty(leg) && ~strcmpi(get(leg,'BeingDeleted'),'on')
  legon=true;
else
  legon=false;
end
ltogg = uigettoolbar(fig,'Annotation.InsertLegend');
lmenu = findall(fig,'Tag','figMenuInsertLegend');

if legon
  if ~isempty(ltogg)
    set(ltogg,'state','on');
  end
  if ~isempty(lmenu)
    set(lmenu,'checked','on');
  end
else
  if ~isempty(ltogg)
    set(ltogg,'state','off');
  end
  if ~isempty(lmenu)
    set(lmenu,'checked','off');
  end
end
if ~isequal(cax,get(fig,'CurrentAxes'))
  set(fig,'CurrentAxes',cax);
end

%----------------------------------------------------%
% Find any legend in parent of input
function leg = find_legend(ha)

fig = get(ha,'parent');
ax = findobj(fig,'type','axes');
leg=[];
k=1;
while k<=length(ax) && isempty(leg)
  if islegend(ax(k))
    hax = handle(ax(k));
    if isequal(double(hax.axes),ha)
      leg=ax(k);
    end
  end
  k=k+1;
end

%----------------------------------------------------%
% Check if input is a legend
function tf=islegend(ax)

if length(ax) ~= 1 || ~ishandle(ax)
  tf=false;
else
  tf=isa(handle(ax),'scribe.legend');
end

%----------------------------------------------------%
function  [edgecol,facecol] = patchcolors(leg,h)

cdat = get(h,'Cdata');
facecol = get(h,'FaceColor');
if strcmp(facecol,'interp') | strcmp(facecol,'texturemap')
  if ~all(cdat == cdat(1))
    warning(['Legend not supported for patches with FaceColor = ''',facecol,''''])
  end
  facecol = 'flat';
end
if strcmp(facecol,'flat')
  if size(cdat,3) == 1       % Indexed Color
    k = find(finite(cdat));
    if isempty(k)
      facecol = 'none';
    end
  else                       % RGB values
    facecol = reshape(cdat(1,1,:),1,3);
  end
end

edgecol = get(h,'EdgeColor');
if strcmp(edgecol,'interp')
  if ~all(cdat == cdat(1))
    warning('Legend not supported for patches with EdgeColor = ''interp''.')
  end
  edgecol = 'flat';
end
if strcmp(edgecol,'flat')
  if size(cdat,3) == 1      % Indexed Color
    k = find(finite(cdat));
    if isempty(k)
      edgecol = 'none';
    end
  else                      % RGB values
    edgecol = reshape(cdat(1,1,:),1,3);
  end
end

%------------------------------------------------------------------%
function [facevertcdata,facevertadata] = patchvdata(leg,h)

cdat = get(h,'CData');
if isempty(cdat)
  %Set this as the first index in the colormap.  I would like to set it as
  %white [1 1 1], but painters complains when given RGB CData.
  facecol = [1];
elseif size(cdat,3) == 1 % Indexed Color
                         % facecol = cdat(1,1,1); %<-- may not be representative
                         % use mean cdata value
  facecol = mean(reshape(cdat,1,prod(size(cdat))));
elseif size(cdat,3) == 3 % RGB values
  facecol = reshape(cdat(1,1,:),1,3);
else
  facecol = [1];
end

xdat = get(h,'XData');

if length(xdat) == 1
  facevertcdata = [facecol];
else
  facevertcdata = [facecol;facecol;facecol;facecol];
end

oldErr=lasterr;
try
  facealpha=get(h,'FaceVertexAlphaData');
catch
  try
    facealpha=get(h,'AlphaData');
  catch
    facealpha=1;
  end
end
lasterr(oldErr);

if length(facealpha)<1
  facealpha=1;
else
  facealpha=facealpha(1);
end

if length(xdat) == 1
  facevertadata = [facealpha];
else
  facevertadata = [facealpha;facealpha;facealpha;facealpha];
end

%-------------------------------------------------------------------%
%                Legend Context Menu
%-------------------------------------------------------------------%

%-------------------------------------------------------------------%
function update_contextmenu(h,onoff)

h = handle(h);
fig = ancestor(h,'figure');
uic = get(h,'UIContextMenu');
if ~isempty(uic)
  set(h.ItemText,'UIContextMenu',uic);
  % check correct interpreter
  plotedit({'update_enumstrprop_menu_checked',h,'Interpreter',...
            uic,'Interpreter', {'latex','tex','none'},...
            {'latex','tex','none'}});
  % check correct location item
  plotedit({'update_enumstrprop_menu_checked',h,'Location',...
            uic,'Location', {'Best','Inside Top Right', ...
                      'Outside Top Right','Inside Bottom Right',...
                      'Inside Top Left','Outside Top Left',...
                      'Inside Bottom Left'},...
            {'best','TR','TE','BR','TL','TW','BL'}});
  % check correct orientation item
  plotedit({'update_enumstrprop_menu_checked',h,'Orientation',...
            uic,'Orientation', {'vertical','horizontal'},...
            {'vertical','horizontal'}});
  % check correct linewidth item
  plotedit({'update_numprop_menu_checked',h,'LineWidth',uic,...
            'Line Width','%1.1f'});
end

%-------------------------------------------------------------------%
function update_contextmenu_cb(hSrc,evdata,varargin)
update_contextmenu(varargin{:})

%--------------------------------------------------------------------%
function set_contextmenu(h,onoff)

fig = ancestor(h,'figure');
uic = get(h,'UIContextMenu');
if isempty(uic)
  uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                      {@update_contextmenu_cb,h});
  plotedit({'add_cutcopyclear_menus',uic,h,'off'});
  % color
  plotedit({'add_colorprop_menu',uic,h,'on'});
  % edge color (xcolor and ycolor)
  plotedit({'add_colorprop_menu',uic,h,'off','Edge','Edge'});
  % line width
  plotedit({'create_numprop_menu',h,'LineWidth',uic,'Line Width','off',...
                      [.5,1,2,3,4,5,6,7,8,9,10,12],'%1.1f'});
  % font properties
  plotedit({'add_fontprops_menu',uic,h,'off'});
  % interpreter
  plotedit({'create_enumstrprop_menu',h,'Interpreter',uic,'Interpreter','off',...
                          {'latex','tex','none'},{'latex','tex','none'}});
  % location
  plotedit({'create_enumstrprop_menu',h,'Location',uic,'Location','off',...
                          {'Best','Inside North East','Outside North East','Inside South East',...
                      'Inside North West','Outside North West','Inside South West'},...
                          {'Best','NorthEast','NorthEastOutside','SouthEast','NorthWest','NorthWestOutside','SouthWest'}});
  % orientation
  plotedit({'create_enumstrprop_menu',h,'Orientation',uic,'Orientation','off',...
                          {'vertical','horizontal'},{'vertical','horizontal'}});
  % properties, mcode
  plotedit({'add_propsandmcode_menus',uic,h});
  % set
  set(h,'uicontextmenu',uic);
  % set legend component context menus
  update_contextmenu(h,'on')
end

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
