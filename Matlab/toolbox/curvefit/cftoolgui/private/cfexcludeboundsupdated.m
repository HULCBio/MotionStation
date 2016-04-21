function cfexcludeboundsupdated(xlo,xhi,ylo,yhi,xlotest,xhitest,ylotest,yhitest)
%CFEXCLUDEBOUNDSUPDATED  Update exclusion graph in response to a bounds update
%
%   CFEXCLUDEBOUNDSUPDATED(XLO,XHI,YLO,YHI,XLOTEST,XHITEST,YLOTEST,YHITEST)
%   updates the graph to reflect the new bounds obtained from the java panel.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:39:45 $

% Find the exclusion graph's figure window
t = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Child');
f = findobj(c,'flat','Type','figure','Tag','cfexcludegraph');
set(0,'ShowHiddenHandles',t);

% Find axis limits and patches
h = findall(f,'Type','patch');
if isempty(h), return; end
p = findall(h,'flat','Tag','xlo');
ax = get(p,'Parent');
xlim = get(ax,'XLim');
ylim = get(ax,'YLim');

% Remember for later
inxlo = xlo;
inxhi = xhi;
inylo = ylo;
inyhi = yhi;

% For each patch we can find (should be all), update limits
if ~isempty(p)
   xlo = max(xlo,xlim(1));
   xp = get(p,'XData');
   xp(2:3) = xlo;
   set(p,'XData',xp);
end
p = findall(h,'flat','Tag','xhi');
if ~isempty(p)
   xhi = min(xhi,xlim(2));
   xp = get(p,'XData');
   xp(2:3) = xhi;
   set(p,'XData',xp);
end

p = findall(h,'flat','Tag','ylo');
if ~isempty(p)
   ylo = max(ylo,ylim(1));
   yp = get(p,'YData');
   yp(2:3) = ylo;
   set(p,'YData',yp);
end
p = findall(h,'flat','Tag','yhi');
if ~isempty(p)
   yhi = min(yhi,ylim(2));
   yp = get(p,'YData');
   yp(2:3) = yhi;
   set(p,'YData',yp);
end

% Update stored in-bounds indicator
ud = get(ax,'UserData');
x = ud{1};
y = ud{2};
excl = ud{3};
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

ud{8} = inbounds;
set(ax,'UserData',ud);

% Update graph and its legend
ud = get(f,'UserData');
func = ud{2};                     % to update excluded points
feval(func,f,excl,'java',1);
func = ud{5};                     % to update legend
feval(func,ax,inxlo,inxhi,inylo,inyhi);
