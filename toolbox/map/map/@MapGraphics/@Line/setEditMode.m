function setEditMode(this,editing)
%setEditMode Make Line editable/un-editable.
%
%   setEditMode(EDITING) makes the line editable if EDITING is true and
%   un-editable if EDITING is false.  If the line is editable, the ends of the
%   line can be moved individually, or the entire line can be moved (preserving
%   length and slope).

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:55:54 $

if editing
  set(this,'ButtonDownFcn',{@editLine this});
  xdata = get(this,'Xdata');
  ydata = get(this,'Ydata');
  this.LineCenter = [diff(xdata)/2 + xdata(1),diff(ydata)/2 + ydata(1)];
else
  set(this,'Selected','off','ButtonDownFcn','');
end

function editLine(hSrc,event,this)
ax = get(this,'Parent');
fig = get(ax,'Parent');

% Only one item selected at a time.
set(get(ax,'Children'),'Selected','off');
set(this,'Selected','on');

% Enable Cut and Copy menu items - Move this out of here!!
cutMenu = findall(fig,'Tag','cut');
copyMenu = findall(fig,'Tag','copy');
set([cutMenu,copyMenu],'Enable','on');

selType = get(fig,'SelectionType');
if strcmp(selType,'open') % double-click
  inspect(this);
elseif strcmp(selType,'normal') % Single click/drag
  set(fig,'Pointer','fleur');
  p = get(ax,'CurrentPoint');
  p = [p(1) p(3)];
  
  endPoints = [get(this,'xdata')' get(this,'ydata')'];
  lineEnd1 = endPoints(1,:);
  lineEnd2 = endPoints(2,:);
  
  % Calculate distances to each end of the line
  totalLineLength = distance(lineEnd1,lineEnd2);
  toEnds = [distance(p,lineEnd1) distance(p,lineEnd2)]; 
  
  % Line end is either 1 or 2
  lineEnd = getNearestLineEnd(toEnds);
  
  % Calculate ratio of length to closest line end to total line length
  rat = toEnds(lineEnd) / totalLineLength;
  
  % Determine line editing function
  if rat < 0.1
    % Only move the position of one of the line ends
    fun = @moveLineEnd;
  else
    % Move the center of the line, preserving length and slope
    fun = @moveLine;
  end
  
  set(fig,'WindowButtonMotionFcn',{fun this lineEnd});
  set(fig,'WindowButtonUpFcn',{@windowButtonUp this});
end

function lineEnd = getNearestLineEnd(toEnds)
if toEnds(1) <= toEnds(2)
  lineEnd = 1;
elseif toEnds(1) > toEnds(2)
lineEnd = 2;
end

function moveLineEnd(hSrc,event,this,lineEnd)
p = get(get(this,'Parent'),'CurrentPoint');
p = [p(1) p(3)];
xData = get(this,'Xdata');
yData = get(this,'Ydata');
xData(lineEnd) = p(1);
yData(lineEnd) = p(2);
set(this,'Xdata',xData);
set(this,'Ydata',yData);

function moveLine(hSrc,event,this,lineEnd)
p = get(get(this,'Parent'),'CurrentPoint');
p = [p(1) p(3)];
xData = get(this,'Xdata');
yData = get(this,'Ydata');
diffXY = p - this.LineCenter;
newXData = xData + diffXY(1);
newYData = yData + diffXY(2);
set(this,'XData',newXData,'YData',newYData);
this.LineCenter = [diff(newXData)/2 + newXData(1),...
                   diff(newYData)/2 + newYData(1)];

function windowButtonUp(hSrc,event,this)
fig = get(get(this,'Parent'),'Parent');
set(fig,'WindowButtonMotionFcn','');
set(fig,'Pointer','arrow');

function d = distance(p1,p2)
% d = sqrt(a^2 + b^2)
d = sqrt((p1(1) - p2(1))^2 + (p1(2) - p2(2))^2);
