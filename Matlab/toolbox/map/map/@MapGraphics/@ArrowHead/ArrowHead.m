function this = ArrowHead(hLine)
%ARROWHEAD
%
%   H = ArrowHead(hLine)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:48:47 $

this = MapGraphics.ArrowHead('Parent',get(hLine,'Parent'));
this.Parent = get(hLine,'Parent');

this.Line = hLine;
mAxes = get(handle(this.Parent),'MasterAxes');
this.listeners = [handle.listener(mAxes,mAxes.findprop('XLim'),...
                                   'PropertyPostSet',{@moveArrow this});
                  handle.listener(mAxes,mAxes.findprop('YLim'),...
                                   'PropertyPostSet',{@moveArrow this})];
drawArrow(this);

function drawArrow(this)

ax = this.Parent;
fig = get(ax,'Parent');

[xt,yt] = buildarrow(this,this.Line,double(ax));

c = get(this.Line,'Color');

set(this,'Parent',double(ax),'XData',xt,'YData',yt,'FaceColor',c, ...
         'EdgeColor','None','Visible',get(this.Line,'Visible'),...
         'HandleVisibility','off');

this.listeners = [this.listeners;...
                  handle.listener(this.Line,findprop(handle(this.Line),'XData'),...
                                  'PropertyPostSet',{@moveArrow this});
                  handle.listener(this.Line,findprop(handle(this.Line),'YData'),...
                                  'PropertyPostSet',{@moveArrow this});...
                  handle.listener(this.Line,findprop(handle(this.Line),'Color'),...
                                  'PropertyPostSet',{@setColor this});...
                  handle.listener(this.Line,findprop(handle(this.Line),'Visible'),...
                                  'PropertyPostSet',{@setVisible this});...
                 handle.listener(this,findprop(this,'ArrowHeight'),...
                                  'PropertyPostSet',{@setArrowSize this})];

set(this.Line,'DeleteFcn',{@delArrowhead this});
set(this,'DeleteFcn',{@delLine this});

toolbar = findall(fig,'type','uitoolbar');
toolButton = findall(toolbar,'ToolTipString','Insert Arrow');
set(toolButton,'State','off');

function setArrowSize(hSrc,event,this)
ax = get(this,'Parent');
[xt,yt] = buildarrow(this,this.Line,ax);
set(this,'XData',xt);
set(this,'YData',yt);

function setVisible(hSrc,event,this)
this.Visible = this.Line.Visible;

function setColor(hSrc,event,this)
this.FaceColor = this.Line.Color;

function moveArrow(hSrc,event,this)
[ah,aw] = getArrowheadSize(this,this.Line,this.Line.Parent);

[co,si] = getCosSin(this.Line);

[xoffset, yoffset] = getOffsets(this.Line);

xt = [ -ah,  -ah, 0,   -ah, -ah ];
yt = [   0, aw/2, 0, -aw/2,   0 ];

[xt,yt] = rotateArrowhead(xt,yt,co,si);

xt = xt + xoffset;
yt = yt + yoffset;
set(this,'XData',xt,'YData',yt);

function [xt, yt] = buildarrow(this,lh, ax)
% returns x and y coord vectors for an arrow head

[ah,aw] = getArrowheadSize(this,lh,ax);

[co,si] = getCosSin(lh);

[xoffset, yoffset] = getOffsets(lh);

scaleLine(lh,ah,co,si);

xt = [ -ah,  -ah, 0,   -ah, -ah ];
yt = [   0, aw/2, 0, -aw/2,   0 ];

[xt,yt] = rotateArrowhead(xt,yt,co,si);

xt = xt + xoffset;
yt = yt + yoffset;

function [x2, y2] = getOffsets(lh)
% Determine the slope of the line.
% Use the last two points of the curve.
X = get(lh, 'XData');
Y = get(lh, 'YData');
x1 = X(end - 1);
x2 = X(end);
y1 = Y(end - 1);
y2 = Y(end);

function [co,si] = getCosSin(lh)
% Determine the slope of the line.
% Use the last two points of the curve.
X = get(lh, 'XData');
Y = get(lh, 'YData');
x1 = X(end - 1);
x2 = X(end);
y1 = Y(end - 1);
y2 = Y(end);
xl = x2 - x1; 
yl = y2 - y1;
hy = (xl^2 + yl^2)^.5;

% calculate the cosine and sine
co =  xl / hy;
si =  yl / hy;

function [xt,yt] = rotateArrowhead(xt,yt,co,si)
% rotate the triangle based on the slope of the last line
foo = [co -si; si  co] * [xt; yt];
    
% convert points back to to data units and add in the offset
xt = foo(1,:);
yt = foo(2,:);

function scaleLine(lh,ah,co,si)
% Determine the slope of the line.
% Use the last two points of the curve.
X = get(lh, 'XData');
Y = get(lh, 'YData');
x1 = X(end - 1);
x2 = X(end);
y1 = Y(end - 1);
y2 = Y(end);

% scale the line down
hlx2=x2-ah*co;
hly2=y2-ah*si;

set(lh,'XData', [X(1) hlx2], 'YData', [Y(1) hly2]);


function [ah,aw] = getArrowheadSize(this,lh,ax)
% Get axis width and height in points
oldUnits = get(ax,'Units');
set(ax,'Units','points');
Pos = get(ax,'Position');
set(ax,'Units',oldUnits);
w = Pos(3);
h = Pos(4);

% Get axis limits
xlim = get(ax,'XLim');
ylim = get(ax,'YLim');

% Calculate number of data units/point
xres = diff(xlim) / w;
yres = diff(ylim) / h;

ah = this.ArrowHeight; % Default arrow height (in points)

% get the line width
lw = get(lh, 'LineWidth');
if (iscell(lw))
    lw = lw{end};
end

% scale arrow height by line width
ah = ah * lw/2;

% 3 : 2 aspect ratio
aw = ah * .66;

% Scale w,h by data units per point
ah = ah * yres;
aw = aw * xres;

% rescales the arrow height and width to retain original
% size.
mAxes = get(handle(ax),'MasterAxes');
origXlim = get(mAxes,'OrigXLim');
origYlim = get(mAxes,'OrigYLim');
ah = ah * origYlim/ylim;
aw = aw * origYlim/ylim;

function delArrowhead(hSrc,event,this)
delete(this);

function delLine(hSrc,event,this)
delete(this.line);

