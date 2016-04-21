function cfgraphexclude(excludePanel,dsname,excl,xlo,xhi,ylo,yhi,xlotest,xhitest,ylotest,yhitest)
%CFGRAPHEXCLUDE  Create graph for selecting (x,y) pairs to exclude
%   CFGRAPHEXCLUDE(EXCLUDEPANEL,DSNAME,EXCL) creates a graph tied to
%   the Java exclusion panel EXCLUDEPANEL, for dataset DSNAME, with
%   current exclusion vector EXCL.  It provides a graphical way to
%   modify that exclusion vector.
%
%   Additional arguments specify lower and upper bounds on x and y,
%   and whether points on the boundary are excluded.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.15.4.4 $  $Date: 2004/03/02 21:46:07 $ 

% Use old figure if any
t = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Child');
f = findobj(c,'flat','Type','figure','Tag','cfexcludegraph');
set(0,'ShowHiddenHandles',t);
if ~isempty(f)
   figure(f)
   return
end

% We're excluding based on data in one dataset
ds = find(getdsdb,'name',dsname);
if isempty(ds)
   return
end
x = ds.x;
y = ds.y;
xname = ds.xname;
yname = ds.yname;

if nargin<3
   excl = logical(zeros(size(x)));
else
   excl = excl(:);
end

% Make a figure to receive graph
% Userdata: java window handle, callback, click point, incl/excl flag
figcolor = get(0,'defaultuicontrolbackgroundcolor');
subfig = figure('IntegerHandle','off','Units','pixels',...
                'HandleVisibility','callback',...
                'name','Select Points for Exclusion Rule',...
                'numbertitle','off',...
                'color',figcolor,...
                'Tag','cfexcludegraph',...
                'ResizeFcn',@resizeselect,...
                'UserData',{excludePanel @updateexcl 0 0 @exclupdatelegend},...
                'doublebuffer','on',...
                'Dock','off');
setcallbacks([],[],subfig);

xlim = [min(x) max(x)];
xlim = xlim + .05 * [-1 1] * diff(xlim);
ylim = [min(y) max(y)];
ylim = ylim + .05 * [-1 1] * diff(ylim);
if xlim(1)==xlim(2)
   xlim = xlim(1) + [-1 1] * max(1,eps(xlim(1)));
end
if ylim(1)==ylim(2)
   ylim = ylim(1) + [-1 1] * max(1,eps(ylim(1)));
end
ax = axes('Parent',subfig,'Box','on','XLim',xlim,'YLim',ylim);

% Remove menus
set(subfig,'Menubar','none');

% Place data points into graph according to current selection
excl = logical(excl);
if xlotest==1
   inbounds = x>=xlo;
else
   inbounds = x>xlo;
end
if xhitest==1
   inbounds = inbounds & x<=xhi;
else
   inbounds = inbounds & x<xhi;
end
if ylotest==1
   inbounds = inbounds & y>=ylo;
else
   inbounds = inbounds & y>ylo;
end
if yhitest==1
   inbounds = inbounds & y<=yhi;
else
   inbounds = inbounds & y<yhi;
end

t = inbounds & ~excl;
l1 = line('XData',x(t),'YData',y(t),...
          'Color','b','Marker','o','LineStyle','none',...
          'Parent',ax,'Tag','included');
t = inbounds & excl;
l2 = line('XData',x(t),'YData',y(t),...
          'Color','r','Marker','x','LineStyle','none',...
          'Parent',ax,'Tag','excluded');
t = ~inbounds & ~excl;
l3 = line('XData',x(t),'YData',y(t),...
          'Color',figcolor/2,'Marker','o','LineStyle','none',...
          'Parent',ax);
t = ~inbounds & excl;
l4 = line('XData',x(t),'YData',y(t),...
          'Color',figcolor/2,'Marker','x','LineStyle','none',...
          'Parent',ax);
alllines = [l1 l2 l3 l4];

% Remember for later
inxlo = xlo;
inxhi = xhi;
inylo = ylo;
inyhi = yhi;

% Create patches to show the area outside the domain and range
xlo = max(xlo,xlim(1));
xp = [xlim(1) xlo xlo xlim(1)];
yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
gr = [.9 .9 .9];
p1=patch(xp,yp,gr,'LineStyle','none','Tag','xlo','Parent',ax);
xhi = min(xhi,xlim(2));
xp = [xlim(2) xhi xhi xlim(2)];
yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
p2=patch(xp,yp,gr,'LineStyle','none','Tag','xhi','Parent',ax);

ylo = max(ylo,ylim(1));
xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
yp = [ylim(1) ylo ylo ylim(1)];
p3=patch(xp,yp,gr,'LineStyle','none','Tag','ylo','Parent',ax);
yhi = min(yhi,ylim(2));
xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
yp = [ylim(2) yhi yhi ylim(2)];
p4=patch(xp,yp,gr,'LineStyle','none','Tag','yhi','Parent',ax);

set(ax,'Child',[alllines p1 p2 p3 p4]);

hFrame = uicontrol(subfig,'style','frame','units','pixels');

% Add some buttons
e1 = get(subfig,'Position');
figwidth = e1(3);

b0 = uicontrol(subfig,'Units','pixels', 'Visible','off', ...
                      'String','Close', 'Parent',subfig, ...
                      'TooltipString','Close Selection Window', ...
                      'Callback',{@buttonselect 'close'}, ...
                      'Tag','close');
b1 = uicontrol(subfig,'Units','pixels', 'Visible','off',...
                      'String','Include All', 'Parent',subfig, ...
                      'TooltipString','Include All Points', ...
                      'Callback',{@buttonselect 'include'}, ...
                      'Tag','include');
b2 = uicontrol(subfig,'Units','pixels', 'Visible','off',...
                      'String','Exclude All', 'Parent',subfig, ...
                      'TooltipString','Exclude All Points', ...
                      'Callback',{@buttonselect 'exclude'}, ...
                      'Tag','exclude');
e1 = get(b1,'Extent');
e2 = get(b2,'Extent');
bheight = 1.5 * e1(4);        % 1.5 * text height
border = bheight/4;           % border between buttons
margin = bheight/2;           % around text within button
bwidth = max(e1(3),e2(3)) + 2*margin;
e1 = [figwidth-bwidth-border, border, bwidth, bheight];
set(b0,'Position',e1,'Visible','on');
e1(2) = e1(2) + 1.5*bheight + border;
set(b1,'Position',e1,'Visible','on');
e1(2) = e1(2) + bheight + border;
set(b2,'Position',e1,'Visible','on');

% Add controls to specify exclusion or inclusion
e1(2) = e1(2) + 2*bheight;
b3 = uicontrol(subfig,'Style','radio','String','Includes Them',...
                      'Units','Pixels','Position',e1,'Value',0,...
                      'HorizontalAlignment', 'left',...
                      'TooltipString','Mouse Selection Includes Points',...
                      'CallBack',{@buttonselect 'mouseinclude'},...
                      'Tag','mouseinclude','Visible','off');
e2 = get(b3,'Extent');
e1(4) = e2(4);
set(b3,'Position',e1','Visible','on');
e1(2) = e1(2) + e2(4);
b4 = uicontrol(subfig,'Style','radio','String','Excludes Them',...
                      'Units','Pixels','Position',e1,'Value',1,...
                      'HorizontalAlignment', 'left',...
                      'TooltipString','Mouse Selection Excludes Points',...
                      'CallBack',{@buttonselect 'mouseexclude'},...
                      'Tag','mouseexclude');
e1(2) = e1(2) + e2(4);
b5 = uicontrol(subfig,'Style','text','String','Selecting Points:',...
                      'HorizontalAlignment','left',...
                      'Units','Pixels','Position',e1);

% Add controls and labels for variable selection
xbottom = e1(2) + 1.5*bheight;
e1(2) = xbottom;
fieldwidth = e1(3);
e1(4) = bheight;
b6 = uicontrol(subfig,'Style','text','String','X: ',...
                      'Units','Pixels','Position',e1,...
                      'HorizontalAlignment','left',...
                      'Tag','xlabel','Visible','off');
e2 = get(b6,'Extent');
labelwidth = e2(3);
e1(1) = e1(1) - labelwidth;
e1(3) = labelwidth;
labelheight = e2(4);
e1(4) = labelheight;
set(b6,'Position',e1','Visible','on');

ybottom = e1(2) + bheight;
e1(2) = ybottom;
b7 = uicontrol(subfig,'Style','text','String','Y: ',...
                      'Units','Pixels','Position',e1,...
                      'HorizontalAlignment','left',...
                      'TooltipString','Select Y Variable or Residuals',...
                      'Tag','ylabel');

e1(1) = e1(1) + labelwidth;
e1(2) = xbottom;
e1(3) = fieldwidth;
b8 = uicontrol(subfig,'Style','text','String',xname,...
                      'Units','Pixels','Position',e1,...
                      'HorizontalAlignment','left',...
                      'Tag','xname');

e1(2) = ybottom - (bheight-labelheight)/2;
e1(4) = bheight;
allynames = {yname};
allfits = cfgetallfits;
for j=1:length(allfits)
   f = allfits{j};
   if isequal(f.dataset,dsname) & f.isGood
      allynames{end+1} = sprintf('%s residuals',f.name);
   end
end

b9 = uicontrol(subfig,'Style','popup','String',allynames,...
                      'Units','Pixels','Position',e1,...
                      'HorizontalAlignment','left',...
                      'BackgroundColor','w',...
                      'Callback',{@changey},...
                      'TooltipString','Select Y Variable or Residuals',...
                      'Tag','yname');

% Push b3-b5 over a bit
for bj = [b3 b4 b5]
   e1 = get(bj,'Position');
   e1(1) = e1(1) - labelwidth;
   e1(3) = e1(3) + labelwidth;
   set(bj,'Position',e1);
end

% Restore toolbar but keep only zoom tools
set(subfig,'toolbar','figure');
h = findall(subfig,'Type','uitoolbar');
h1 = findall(h);        % Get all children
h1(h1==h) = [];         % Not including the toolbar itself
h2 = findall(h1,'flat','TooltipString','Zoom In');
h1(h2==h1) = [];
h2 = findall(h1,'flat','TooltipString','Zoom Out');
h1(h2==h1) = [];
delete(h1);

% Stash everything for callback
hcontrols = [b0 b1 b2 b3 b4 b5 b8 b9 b6 b7 hFrame];
listener = [];    % formerly used, now just a placeholder
ud = {x y excl alllines listener hcontrols ds inbounds};
set(ax,'Userdata',ud);

% Adjust the layout
layoutfigure(subfig);

% Update the legend
exclupdatelegend(ax,inxlo,inxhi,inylo,inyhi);

set(subfig,'HandleVisibility','callback');
cfgetset('cfsubfig',subfig);

return


% ------------- function to initiate graphical selection
function startselect(varargin)

% Save mouse position and start a rubber band operation
subfig = gcbf;
ax = getaxes(subfig);
curax = ancestor(hittest(subfig),'hg.axes');
if ~isequal(ax, curax)
   return;   % ignore clicks on the legend
end
pt0 = get(ax, 'CurrentPoint');
ud = get(subfig,'UserData');
ud{3} = pt0;
set(subfig,'Userdata',ud);
rbbox;


% ------------- function to complete graphical selection
function endselect(varargin)

% Get mouse position at button down and button up
subfig = gcbf;
ax = getaxes(subfig);
ud = get(subfig,'Userdata');
pt0 = ud{3};
pt1 = get(ax, 'CurrentPoint');
swapped = ud{4};

% Check that we've had a button down
if size(pt0,1)<2 | size(pt0,2)<2
   return;
end
ud{3} = 0;
set(subfig,'UserData',ud);   

% Force inside axis limits
xlim = get(ax, 'XLim');
ylim = get(ax, 'YLim');
x0 = min(pt0(1,1), pt1(1,1));
y0 = min(pt0(1,2), pt1(1,2));
x1 = max(pt0(1,1), pt1(1,1));
y1 = max(pt0(1,2), pt1(1,2));
if x1<xlim(1) | x0>xlim(2) | y1<ylim(1) | y0>ylim(2)
   return
end
x0 = max(xlim(1), x0);
y0 = max(ylim(1), y0);
x1 = min(xlim(2), x1);
y1 = min(ylim(2), y1);

% Get stored information
ud = get(ax,'Userdata');
x = ud{1};
y = ud{2};
excl = ud{3};
alllines = ud{4};
l1 = alllines(1);
l2 = alllines(2);
inbounds = ud{8};
excluding = ~isequal(get(subfig,'SelectionType'),'alt');

h = [];
rectangular = (x0 ~= x1) & (y0 ~= y1); % a rubber band selection?

% Get distance from each symbol to selection (box or point)
xrange = diff(get(ax,'Xlim'));
yrange = diff(get(ax,'Ylim'));
xd = max(0, (x0-x)/xrange) + max(0, (x-x1)/xrange) + ~isfinite(x);
yd = max(0, (y0-y)/yrange) + max(0, (y-y1)/yrange) + ~isfinite(y);
d = xd.*xd + yd.*yd;
d1 = min(d);
if (rectangular)
   % Select points inside rectangle
   idx = find(inbounds & d<=0);
elseif d1<0.02
   % Select points at or very close to selection point
   idx = find(inbounds & d<=d1+2e-4);
else
   % Too far, no selection
   idx = [];
end

% Update exclusion vector
if swapped
   excluding = ~excluding;
end
if (length(idx) > 0)
   newexcl = excl;
   if excluding
      newexcl(idx) = 1;
   else
      newexcl(idx) = 0;
   end

   % Update stored results and graph
   if ~isequal(excl,newexcl)
      updateexcl(ax,newexcl,'graph');
   end
end


% ------------- function to perform callback functions for buttons
function buttonselect(varargin)

subfig = gcbf;
action = varargin{3};
switch action
 % Close button, delete figure
 case 'close'
   delete(subfig);

 % Radio button, update other button and save state
 case {'mouseinclude' 'mouseexclude'}
   if isequal(action,'mouseinclude')
      otherbutton = findobj(get(gcbo,'Parent'),'Tag','mouseexclude');
      newstate = 1;
   else
      otherbutton = findobj(get(gcbo,'Parent'),'Tag','mouseinclude');
      newstate = 0;
   end
   set(otherbutton,'Value',0);
   ud = get(subfig,'UserData');
   ud{4} = newstate;
   set(subfig,'UserData',ud);
  
 % Push button, include or exclude everything
 otherwise
   % Get stored information
   ax = getaxes(subfig);
   ud = get(ax,'Userdata');
   inbounds = ud{8};
   excl = ud{3};
   if isequal(action,'exclude')
      excl(inbounds) = 1;
   else
      excl(inbounds) = 0;
   end
   
   % Update stored results and graph
   updateexcl(ax,excl,'graph');
end


% ------------- function to implement change in y variable selection
function changey(varargin)

subfig = gcbf;
ax = getaxes(subfig);
ud = get(ax,'Userdata');
h = gcbo;
excl = ud{3};
ds = ud{7};

% Get y data, then try to get residuals if requested; shouldn't fail
v = get(h,'Value');
foundit = 0;
y = ds.y;
fitdb = getfitdb;
if v>1
   allynames = get(h,'String');
   yname = allynames{v};
   if length(yname)>10 & isequal(yname(end-9:end),' residuals')
      fitname = yname(1:end-10);
      f = find(fitdb,'name',fitname);
      if ~isempty(f) & f.isGood
         x = ds.x;
         yobs = ds.y;
         y = yobs - feval(f.fit,x);
         foundit = 1;
      end
   end
end

% If anything went wrong, revert to y data
if v>1 & ~foundit
   set(h,'Value',1);
end

% Update graph
ud{2} = y;
set(ax,'UserData',ud);
updateexcl(ax,excl,'graph');
ylim = [min(y) max(y)];
if ylim(1)==ylim(2)
   ylim = ylim + [-1 1];
else
   ylim = ylim + .05 * [-1 1] * diff(ylim);
end
set(ax,'YLim',ylim);


% ----------- Takes new exclusion vector and propagates changes
function updateexcl(ax,newexcl,src,bndschng)
%   ax is the axes or figure handle, newexcl is the new exclusion
%   vector, src is the source of the change ('graph' or 'java'),
%   and bndschng is a flag that may indicate a change in bounds,
%   so it forces an update even if no change in point exclusion

if isequal(get(ax,'Type'),'figure')
   ax = getaxes(ax);
end
if nargin<4
   bndschng = 0;
end

newexcl = newexcl(:);
ud = get(ax,'Userdata');
oldexcl = ud{3};
if isequal(src,'java') & isequal(oldexcl,newexcl) & ~bndschng
   return
end

x = ud{1};
y = ud{2};
alllines = ud{4};

% Save exclusion vector
excl = logical(newexcl);
ud{3} = excl;
set(ax,'Userdata',ud);

% Update graph
inbounds = ud{8};
t = inbounds & ~excl;
set(alllines(1),'XData',x(t),'YData',y(t));
t = inbounds & excl;
set(alllines(2),'XData',x(t),'YData',y(t));
t = ~inbounds & ~excl;
set(alllines(3),'XData',x(t),'YData',y(t));
t = ~inbounds & excl;
set(alllines(4),'XData',x(t),'YData',y(t));

% Update table in java panel
if ~isequal(src,'java')
   f = get(ax,'Parent');
   ud = get(f,'UserData');
   epanel = ud{1};
   epanel.excludeThesePoints(excl);
end


% ----------- Layout items in figure after resize
function resizeselect(varargin)

layoutfigure(gcbf)


% ----------- Layout items in figure
function layoutfigure(subfig)

% Get info, check for premature resize during figure creation
ax = getaxes(subfig);
ud = get(ax,'Userdata');
if isempty(ud), return; end

% Make sure figure does not get too small
figpos = get(subfig,'Position');
if figpos(3)<350 | figpos(4)<330
   temp = getappdata(subfig,'oldpos');
   if figpos(3)<350
      if figpos(1)>temp(1)
         % Tried to shrink from the left
         figpos(1) = figpos(1)+figpos(3)-350;
      end
      figpos(3) = 350;
   end
   if figpos(4)<330
      if figpos(2)>temp(2)
         % Tried to shrink from the bottom
         figpos(2) = figpos(2)+figpos(4)-330;
      end
      figpos(4) = 330;
   end
   update = true;
else
   update = false;
end

% Adjust figure size if necessary
if update
   oldfn = get(subfig,'ResizeFcn');
   set(subfig,'ResizeFcn',[]);
   set(subfig,'Position',figpos);
   set(subfig,'ResizeFcn',oldfn);
   figpos = get(subfig,'Position');
end

setappdata(subfig,'oldpos',figpos);
figwidth = figpos(3);
figheight = figpos(4);

% Get button handles
buttons = ud{6};

% Get some dimensions and adjust button position
axtop = figheight - 15;
e1 = get(buttons(1),'Position');
bwidth = e1(3);
bheight = e1(4);
border = bheight/2;
xpos = figwidth - bwidth - border;
e1(1) = xpos;
set(buttons(1),'Position',e1);
e9 = get(buttons(9),'Position');
minx = xpos - e9(3);

% Make sure the axes won't overlap the controls
u = get(ax,'Units');
set(ax,'Units','pixels');
set(ax,'OuterPosition',[5, 5, max(1,minx-10), max(1,axtop)]);
axpos = get(ax,'Position');
set(ax,'Units',u);

% Adjust the frame
hFrame = buttons(11);
set(hFrame,'Position',[minx-5, 0, figwidth-minx+10, figheight+5]);

% Now try to align the controls with the top of the axes
temp = get(buttons(10),'Position');
vertadj = (axpos(2) + axpos(4)) - (temp(2) + temp(4));

% Some items are aligned on the left
for bj=buttons([1 2 3 7 8])
   e1 = get(bj,'Position');
   e1(1) = xpos;
   if bj ~= buttons(1)
      e1(2) = e1(2) + vertadj;
   end
   set(bj,'Position',e1);
end

% Some are to the left of the preceeding ones
for bj=buttons([4 5 6 9 10])
   e1 = get(bj,'Position');
   e1(1) = minx;
   e1(2) = e1(2) + vertadj;
   set(bj,'Position',e1);
end

% ------------ Get the real axes, not the legend axes
function ax = getaxes(fig)

a = get(fig,'Children');
a = findobj(a,'flat','Type','axes');

ax = [];
for j=1:length(a)
   if ~isa(handle(a(j)),'graph2d.legend') & ...
      ~strcmp(get(a(j),'tag'),'legend')
      ax = a(j);
      break
   end
end


% ------------- Set the callback functions
function setcallbacks(varargin)
if nargin<3
   subfig = gcbf;
else
   subfig = varargin{3};
end

set(subfig, 'WindowButtonDownFcn',@startselect, ...
            'WindowButtonUpFcn',@endselect);


% ------------- Update the exclusion graph legend
function exclupdatelegend(ax,xlo,xhi,ylo,yhi)

% Do we need to add or remove the patch from the legend?
havebnds = any(isfinite([xlo xhi ylo yhi]));
[a,b,c] = legend(ax);
have3rd = (length(c)>2);

if isempty(c) | havebnds~=have3rd
   % Add legend
   h = get(ax,'Child');
   l1 = findobj(h,'flat','Type','line','Tag','included');
   l2 = findobj(h,'flat','Type','line','Tag','excluded');
   p1 = findobj(h,'flat','Type','patch','Tag','xlo');
   if length(p1)>1, p1 = p1(1); end
   
   if havebnds
      legend(ax,[l1 l2 p1], xlate('Included'),xlate('Excluded'),...
             xlate('Outside domain/range'),'location','NorthOutside');
   else
      legend(ax,[l1 l2],xlate('Included'),xlate('Excluded'),...
             'location','NorthOutside');
   end
end

subfig = get(ax,'Parent');
set(subfig,'CurrentAxes',ax);

