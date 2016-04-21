function buttondownfcn2D(hZoom,hAxesVector)
%BUTTONDOWNFCN2D
% Button down function for 2-D zooming

zoom_dir = get(hZoom,'Direction');

switch(zoom_dir)
 case 'out'
     applyzoomfactor(hZoom,hAxesVector,1);
 case 'in'
     localZoom2DIn(hZoom,hAxesVector);
end

%---------------------------------------------------%
function localZoom2DIn(hZoom,hAxesVector)

hFig = get(hZoom,'FigureHandle');

% Get figure current point in pixels
origUnits = get(hFig,'Units');
set(hFig,'Units','Pixels');
new_pt = get(hFig,'CurrentPoint'); 
set(hFig,'Units',origUnits);
set(hZoom,'MousePoint',new_pt);

% First element in the currentAxes is the axes on the 
% top (on which the lines are drawn).
cAx = hAxesVector(1);

% Get the current point on this axes
cp = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);

cpMulAxes = [];
% Get the current point on the other axes too (multiple axes case).
% This will be passed as an argument to the mousebtnupfcn of the zoom
% object where the new axes limits are set.
for k = 2:length(hAxesVector),
    cpAxes = get(hAxesVector(k), 'CurrentPoint');
    cpMulAxes(k-1,:) = cpAxes(1,1:2);
end

x  = ones(2,4) * cp(1);
y  = ones(2,4) * cp(2);

% Display rrbox lines in top axes
hRbboxAxes = hAxesVector(1);

% Get zoom lines
hLines = get(hZoom,'LineHandles');
if all(isempty(hLines)) || all(~ishandle(hLines))
   hLines = localCreateZoomLines(hFig,hRbboxAxes,x,y);
   set(hZoom,'LineHandles',hLines);
else
   set(hLines,'xdata',x(1,:),'ydata',y(1,:)); 
end

origMotionFcn = get(hFig,'WindowButtonMotionFcn');
% Set the window button motion and up fcn's.

set(hFig, 'WindowButtonMotionFcn',...
          {@local2DButtonMotionFcn,hZoom});

set(hFig, 'WindowButtonUpFcn', ...
          {@local2DButtonUpFcn, ...
           hZoom, ...
           cpMulAxes, ...
           origMotionFcn});

%---------------------------------------------------%
function [hLines] = localCreateZoomLines(hFig,hAxes,x,y)

% Create the line for the RbBox.
lineprops.Parent = hAxes;
lineprops.Visible = 'on';
lineprops.EraseMode = 'xor';
lineprops.LineWidth = 1;
lineprops.Color =   [0.65 0.65 0.65];
lineprops.Tag = '_TMWZoomLines';
lineprops.HandleVisibility = 'off';

if get(0,'ScreenDepth') == 8,  
  lineprops.LineWidth = 1;
end

% xxx Call scribefiglisten to prevent zoom button 
% from popping out. 
scribefiglisten(hFig,'off');
hLines = line(x,y,lineprops);
scribefiglisten(hFig,'on');

%---------------------------------------------------%
function local2DButtonMotionFcn(hcbo,eventData,hZoom)

buttonmotionfcn2D(hZoom);

%---------------------------------------------------%
function local2DButtonUpFcn(hcbo, eventData,hZoom,cpMulAxes,origMotionFcn)

hFig = get(hZoom,'FigureHandle');
buttonupfcn2D(hZoom, cpMulAxes);

% Clear window button motion & up functions.
set(hFig,'windowbuttonmotionfcn', origMotionFcn);
set(hFig,'windowbuttonupfcn', '');
set(hZoom,'MousePoint',[]);


