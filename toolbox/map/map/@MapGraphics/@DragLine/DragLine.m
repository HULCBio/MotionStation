function this = DragLine(ax,isArrow,repeatLine)
%DRAGLINE Draw a line on an axis between two points.
%
%  HLine = DragLine(AX)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:48:49 $

if isempty(isArrow)
  isArrow = false;
end

this = MapGraphics.DragLine('XData',[],'YData',[],'ZData',[],...
                            'EraseMode','normal',...
                            'Parent',double(ax),'Visible','off');

this.Finished = false;
this.IsArrow = isArrow;

if (nargin > 2 && repeatLine)
  fig = get(ax,'Parent');
  this.OldPointer = get(fig,'Pointer');
  linego([],[],this,ax);
else
  linestart(ax,this);
end

function linestart(ax,this)
fig = get(ax,'Parent');
this.OldPointer = get(fig,'Pointer');
set(fig,'Pointer','crosshair',...
        'WindowButtonDownFcn',{@linego this ax});

function linego(hSrc,event,this,ax)
fig = get(ax,'Parent');
oldUnits = get(fig,'Units');
set(fig,'Units','pixels');
this.figpt = get(fig,'CurrentPoint');
set(fig,'Units',oldUnits);

set(fig,'CurrentObject',ax);
pt = get(ax,'CurrentPoint');
this.StartX = pt(1);
this.StartY = pt(3);

set(this,'XData',this.StartX,'YData',this.StartY,'Visible','on');

set(fig,...
    'WindowButtonMotionFcn',{@linedrag this ax},...
    'WindowButtonUpFcn',{@linepoint1 this ax});

function linedrag(hSrc,event,this,ax)
pt = get(ax,'CurrentPoint');
set(this,'XData', [this.StartX pt(1)], ...
         'YData', [this.StartY pt(3)]);

function linepoint1(hSrc,event,this,ax)
xUp = get(this,'XData');
yUp = get(this,'YData');
if length(xUp)==1 & length(yUp)==1 % clicked once without dragging
  set(get(ax,'Parent'),...
      'WindowButtonDownFcn',{@linereset hSrc event this ax},...
      'WindowButtonUpFcn','',...
      'WindowButtonMotionFcn',{@linepoint2 this ax});
else % end dragging
feval(@lineend,hSrc,event,this,ax);
end

function linepoint2(hSrc,event,this,ax)
fig = get(ax,'Parent');
set(fig,'CurrentObject',ax);
set(fig,'WindowButtonMotionFcn',{@linedrag this ax},...
        'WindowButtonDownFcn',{@lineend this ax});   

function linereset(hSrc,event,this,ax)
fig = get(ax,'Parent');
set(fig,'Pointer',this.OldPointer,...
        'WindowButtonDownFcn','',...
        'WindowButtonMotionFcn','',...
        'WindowButtonUpFcn','');
toolbar = findall(fig,'type','uitoolbar');
toolButton = findall(toolbar,'ToolTipString','Insert Line');

set(toolButton,'State','off');
this.Finished = true;
this.send('LineFinished',MapGraphics.LineFinished(this));

% This keeps things going
set(fig,'WindowButtonDownFcn',{@insertLine this ax});

function lineend(hSrc,event,this,ax)
fig = get(ax,'Parent');
pt = get(ax,'CurrentPoint');
this.EndX = pt(1);
this.EndY = pt(3);
set(this,'XData', [this.StartX pt(1)], 'YData', [this.StartY pt(3)]);
set(fig,'CurrentObject',ax);

oldUnits = get(fig,'Units');
set(fig,'Units','pixels');
pt = get(fig,'CurrentPoint');
set(fig,'Units',oldUnits);

if this.IsArrow
  this.ArrowHead = this.addArrowHead;
end

feval(@linereset,hSrc,event,this,ax);

function insertLine(hSrc,event,this,ax)
MapGraphics.DragLine(ax,this.IsArrow,true);
