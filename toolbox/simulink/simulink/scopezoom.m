function varargout = scopezoom(guiAction, varargin),
%scopezoom - GUI interface for zoom function
%   Handles buttondown, buttonup and buttonmotion functions for 
%   ZOOM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

switch guiAction,

case 'butmot',
    %
    % Put button motion fcn first, as it gets called iteratively.
    %
    zoomMode = varargin{1};
    i_ZoomButtonMotionFcn(gcbf, zoomMode);

case 'butdwn',
    %
    % Button down fcn 2nd.  We want fast response here too.
    %
    zoomMode = varargin{1};
    i_ZoomButtonDownFcn(gcbf, zoomMode);

case 'butup',
    %
    % Zoom button up fcn for case of zoomin in.
    %
    zoomMode = varargin{1};
    i_ZoomButtonUpFcn(gcbf, zoomMode);

case 'butupOut',
    %
    % Zoom button up fcn for case of zooming out.
    %
    i_ZoomButtonUpOutFcn(gcbf);
    
case 'on',
    %
    % Turn zoom on in normal mode.
    %
    fig = varargin{1};
    zoomMode = 'normal';
    set(fig, 'WindowButtonDownFcn', ['scopezoom butdwn ' zoomMode]);

case 'xonly',
    %
    % Turn zoom on in xonly mode.
    %
    fig = varargin{1};
    i_EnableXonlyMode(fig);
 
case 'yonly',
    %
    % Turn zoom on in yonly mode.
    %
    fig = varargin{1};
    i_EnableYonlyMode(fig);
 
case 'off',
    %
    % Turn zoom off.
    %
    fig = varargin{1};
    i_zoomOff(fig);

case 'reset',
    %
    % Reset the current zoom state.
    %
    fig = varargin{1};
    i_ResetZoomState(fig);
    
case 'restore',
    %
    % Restore to original view and cancel zoom stack
    %
    ax = varargin{1};
    simStatus = varargin{2};
    if strcmp(simStatus, 'running');
      i_RestoreToOriginalView(ax, 'ContextMenu');
    else,
      i_ZoomToOriginalView(ax, 'ContextMenu');
    end
   
otherwise,
    error('Invalid GUI action (guiAction) specified.');
end


% Function =====================================================================
% Button down function for zoom.

function i_ZoomButtonDownFcn(fig, zoomMode),

%
% Find axis under the current point.
% NOTE: The i_FindAxisUnderCurrentPoint function has the side affect of
%   creating the ZoomUserData structure if one does not exist for the 
%   found axis.  The axis under the point is returned (or [] if not found),
%   as well as the handle to the container object for the zoom data.
%
ax = i_FindAxisUnderCurrentPoint(fig);

if ~isempty(ax),

    %
    % Based on the type of buttonpress, zoom in or out.
    %
    switch(GetSelectionType(fig, getZoomDataContainer(fig))),
    
    case 'normal',
        %
        % Zoom in (left click).
        %
        i_ZoomIn(ax, getZoomDataContainer(fig), zoomMode);

    case 'alt',
        %
        % Zoom out one stack level (right click).
        %
        if strcmp(zoomMode,'ContextMenu'),
            i_ZoomOut1Level(ax);
            i_ZoomButtonUpOutFcn(gcbf);
        end

    case 'open',
        %
        % Zoom all the way out to the bottom of the stack.
        %  (double click).
        %
        i_ZoomToOriginalView(ax, zoomMode);
    end
end


% Function =====================================================================
% Get selection type subject to constraint that double clicks only return open
% if they are the result of left clicks.

function SelectionType = GetSelectionType(fig, zoomStruct),

%
% Constrain 'open' to left mouse button.
%
SelectionType = get(fig, 'SelectionType');

if ((strcmp(SelectionType, 'open'))              & ...
    (strcmp(zoomStruct.oldSelectionType, 'alt'))),
    SelectionType = 'alt';
end

%
% Update user data.
%
zoomStruct.oldSelectionType = SelectionType;
updateZoomDataContainer(fig,zoomStruct);


% Function =====================================================================
% Find axes under the current point.  The axes must meet the  the following
% criteria:
%   a) ZLabel userdata cannot be NaN
%      - this allows a mechanism for suppressing zoom
%   b) The axis must currently be in 2-D view
%
% The zoom user data is created if it does not already exist.
%
% OUTPUT:
%  ax - handle of axes or [] if none found 
%  hzoomDataContainer - handle to container for zoom data.
%
% NOTE: NO attempt is made to deal w/ overlapping axes.  In this case,
%        the first axes found will be returned. 
%
function ax = i_FindAxisUnderCurrentPoint(fig)

figChildren = get(fig, 'Children');
allAxes     = findobj(figChildren, 'flat', 'Type', 'axes');

ax         = [];
zoomStruct = [];

%
% Search all axes until find one that falls under current point.  If the
%  zoomUserData does not yet exist, create it.
%
% NOTE: This is done via the axes current point function.  Each axes returns
%       the current point in it's own data units (whether it falls w/in the 
%       axes or not!).  If the current point of a given axes falls w/in it's
%       x and y data, then it is underneath the current point.
%
for i = 1:length(allAxes),
    %
    % Axis handle.
    %
    thisAx = allAxes(i);
  
    %
    % Current point.
    %
    thisAxCp  = get(thisAx,'CurrentPoint');
    thisAxXcp = thisAxCp(1,1);
    thisAxYcp = thisAxCp(1,2);

    %
    % As long as the axes is valid, see if it's under the current point.
    %
    XLim = get(thisAx, 'XLim');
    YLim = get(thisAx, 'YLim');

    %
    % Is this axes under the current point?
    %
    if (((XLim(1) <= thisAxXcp) & (thisAxXcp <= XLim(2)))  &...
        ((YLim(1) <= thisAxYcp) & (thisAxYcp <= YLim(2)))),
      
        %
        % Return this axis.
        %
        ax = thisAx;
        return;
    end
end


% Function =====================================================================
% Button motion function for zoom.

function i_ZoomButtonMotionFcn(fig, zoomMode),

zoomUserStruct = getZoomDataContainer(fig);
hLines         = zoomUserStruct.hLines;
cp             = get(get(gcbf,'CurrentAxes'), 'CurrentPoint'); cp = cp(1,1:2);
xcp            = cp(1);
ycp            = cp(2);

%
% The first point of line 1 is always the zoom origen.
%
XDat   = get(hLines(1), 'XDat');
YDat   = get(hLines(1), 'YDat');
origen = [XDat(1), YDat(1)];

%
% Draw rbbox depending on mode.
%
switch(zoomMode),

case 'normal',
    %
    % Both x and y zoom.
    % RBBOX - lines:
    % 
    %          2
    %    o-------------
    %    |            |
    %  1 |            | 4
    %    |            |
    %    --------------
    %          3
    %

    %
    % Set data for line 1.
    %
    YDat = get(hLines(1), 'YDat');
    YDat(2) = ycp;
    set(hLines(1),'YDat',YDat);

    %
    % Set data for line 1.
    %
    XDat = get(hLines(2),'XDat');
    XDat(2) = xcp;
    set(hLines(2),'XDat',XDat);

    %
    % Set data for line 3.
    %
    XDat = get(hLines(3),'XDat');
    YDat = [ycp ycp];
    XDat(2) = xcp;
    set(hLines(3),'XDat',XDat,'YDat',YDat);

    %
    % Set data for line 4.
    %
    YDat = get(hLines(4), 'YDat');
    XDat = [xcp xcp];
    YDat(2) = ycp;
    set(hLines(4),'XDat',XDat,'YDat',YDat);

case 'xonly',
    %
    % x only zoom.
    % RBBOX - lines (only 1-3 used):
    %   
    %    |     1      |
    %  2 o------------| 3 
    %    |            |
    %             
    
    %
    % Set the end bracket lengths (actually the halfLength).
    %
    YLim = get(get(gcbf,'CurrentAxes'), 'YLim');
    endHalfLength = (YLim(2) - YLim(1)) / 30;

    %
    % Set data for line 1.
    %
    XDat = get(hLines(1),'XDat');
    XDat(2) = xcp;
    set(hLines(1),'XDat',XDat);

    %
    % Set data for line 2.
    %
    YDat = [origen(2) - endHalfLength, origen(2) + endHalfLength];
    set(hLines(2), 'YDat', YDat);

    %
    % Set data for line 3.
    %
    XDat = [xcp xcp];
    YDat = [origen(2) - endHalfLength, origen(2) + endHalfLength];
    set(hLines(3), 'XDat', XDat, 'YDat', YDat);

case 'yonly',
    %
    % y only zoom.
    % RBBOX - lines (only 1-3 used):
    %    2
    %  --o--  
    %    |
    %  1 |
    %    |
    %  -----           
    %    3
    %

    %
    % Set the end bracket lengths (actually the halfLength).
    %
    XLim = get(get(gcbf,'CurrentAxes'), 'XLim');
    endHalfLength = (XLim(2) - XLim(1)) / 30;

    %
    % Set data for line 1.
    %
    YDat = get(hLines(1),'YDat');
    YDat(2) = ycp;
    set(hLines(1),'YDat',YDat);

    %
    % Set data for line 2.
    %
    XDat = [origen(1) - endHalfLength, origen(1) + endHalfLength];
    set(hLines(2), 'XDat', XDat);

    %
    % Set data for line 3.
    %
    YDat = [ycp ycp];
    XDat = [origen(1) - endHalfLength, origen(1) + endHalfLength];
    set(hLines(3), 'XDat', XDat, 'YDat', YDat);
end


% Function =====================================================================
% Button up function for zoom.

function i_ZoomButtonUpFcn(fig, zoomMode),

zoomStruct = getZoomDataContainer(fig);
AxisList   = getCurrentAxisList(fig);
cAx        = get(fig,'CurrentAxes');
hLines     = zoomStruct.hLines;

%
% The first point of line 1 is always the zoom origen.
%
XDat   = get(hLines(1), 'XDat');
YDat   = get(hLines(1), 'YDat');
origen = [XDat(1), YDat(1)];

%
% Get the current limits.
%
currentXLim = get(cAx, 'XLim');
currentYLim = get(cAx, 'YLim');

%
% Perform zoom operation based on zoom mode.
%
switch(zoomMode),

case 'normal',
    %
    % Both x and y zoom.
    % RBBOX - lines:
    % 
    %          2
    %    o-------------
    %    |            |
    %  1 |            | 4
    %    |            |
    %    --------------
    %          3
    %

    %
    % Determine the end point of zoom operation.
    %

    %
    % Get current point.
    %
    cp = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
    xcp = cp(1);
    ycp = cp(2);

    %
    % Clip to current axes.
    %
    if xcp > currentXLim(2),
      xcp = currentXLim(2);
    end
    if xcp < currentXLim(1),
      xcp = currentXLim(1);
    end
    if ycp > currentYLim(2),
      ycp = currentYLim(2);
    end
    if ycp < currentYLim(1),
      ycp = currentYLim(1);
    end

    endPt = [xcp ycp];

    %
    % Determine the Xlimits mode: POINT or RBBOX.
    %
    bPointMode = 0;
    if origen(1) == endPt(1),
      bPointMode = 1;
    end
    
    %
    % Calculate the new X-Limits.
    %
    if (bPointMode == 0),
        %
        % Bounding Box Mode.
        %

        XLim = [origen(1) endPt(1)];
        if XLim(1) > XLim(2),
            XLim = XLim([2 1]);
        end
    else,
        %
        % Point Mode.
        %
      
        %
        % Divide the horizontal into 5 divisions.
        %
        XLim = get(cAx, 'XLim'); XDiff = (XLim(2) - XLim(1)) / 5;
        if strcmp(get(cAx, 'XScale'), 'log'),
            % XLim(1) must be >= 1;

            candidateXMin = xcp - XDiff;
            if candidateXMin < 1,
                xmin  = 1;
                delta = 1 - candidateXMin;
                xmax  = xcp + XDiff + delta;
            else,
                xmin = xcp - XDiff;
                xmax = xcp + XDiff;
            end

            XLim = [xmin xmax];
        else,
            XLim = [xcp - XDiff, xcp + XDiff];
        end
    end  

    %
    % Set new Xlimits.
    % NOTE: Check that the limits aren't equal.  This happens
    %   at very small limits.  In this case, we do nothing.
    %
    resizeHiLites = 0;
    if abs(XLim(1) - XLim(2)) > 1e-10*(abs(XLim(1)) + abs(XLim(2))),
        for i=1:zoomStruct.AXnum,
            set(AxisList(i), 'XLim', XLim);
            resizeHiLites = 1;
        end,                
    else,
        warning('Axis limits cannot be zoomed any further!');
    end

    %
    % Determine the Ylimits mode: POINT or RBBOX.
    %
    bPointMode = 0;
    if origen(2) == endPt(2),
        bPointMode = 1;
    end
    
    %
    % Calculate the new Y-Limits.
    %
    if (bPointMode == 0),
        %
        % Bounding Box Mode.
        %

        YLim = [origen(2) endPt(2)];
        if YLim(1) > YLim(2),
            YLim = YLim([2 1]);
        end
    else,
        %
        % Point Mode.
        %

        %
        % Divide the vertical into 5 divisions.
        %
        YLim = get(cAx, 'YLim'); YDiff = (YLim(2) - YLim(1)) / 5;
        if strcmp(get(cAx, 'YScale'), 'log'),
            % YLim(1) must be >= 1

            candidateYMin = ycp - YDiff;
            if candidateYMin < 1,
                ymin = 1;
                delta = 1 - candidateYMin;
                ymax = ycp + YDiff + delta;
            else,
                ymin = ycp - YDiff;
                ymax = ycp + YDiff;
            end

            YLim = [ymin ymax];

        else,  
            YLim = [ycp - YDiff, ycp + YDiff];
        end
    end  

    %
    % Set new Ylimits.
    % NOTE: Check that the limits aren't equal.  This happens
    %   at very small limits.  In this case, we do nothing.
    %
    if abs(YLim(1) - YLim(2)) > 1e-10*(abs(YLim(1)) + abs(YLim(2))),
        set(cAx, 'YLim', YLim);
        resizeHiLites = 1;
    else,
        warning('Axis limits cannot be zoomed any further!');
    end

    if resizeHiLites
        simscope('ResizeHiLites',fig);
    end
    
case 'xonly',
    %
    % x only zoom.
    % RBBOX - lines (only 1-3 used):
    %   
    %    |     1      |
    %  2 o------------| 3 
    %    |            |
    %             
    %

    %
    % Determine the end point of zoom operation.
    %

    %
    % End pt is the 2nd point of line 1.
    %
    XDat = get(hLines(1), 'XDat');
    xcp = XDat(2);

    %
    % Clip to current axes.
    %
    if xcp > currentXLim(2),
      xcp = currentXLim(2);
    end
    if xcp < currentXLim(1),
      xcp = currentXLim(1);
    end

    endPt = [xcp origen(2)];

    %
    % Determine mode: POINT or RBBOX.
    %
    if xcp == origen(1),
        bPointMode = 1;
    else,
        bPointMode = 0;
    end

    %
    % Determine the new limits.
    %
    if (bPointMode == 0),
        %
        % Bounding Box Mode.
        %

        %
        % Calculate new X Limits
        %
        XLim = [origen(1) endPt(1)];
        if XLim(1) > XLim(2),
            XLim = XLim([2 1]);
        end
    else,
        %
        % Point Mode.
        %

        %
        % Divide the horizontal into 5 divisions.
        %
        XLim = get(cAx, 'XLim'); XDiff = (XLim(2) - XLim(1)) / 5;
        if strcmp(get(cAx, 'XScale'), 'log'),
            % XLim(1) must be >= 1;

            candidateXMin = xcp - XDiff;
            if candidateXMin < 1,
                xmin  = 1;
                delta = 1 - candidateXMin;
                xmax  = xcp + XDiff + delta;
            else,
                xmin = xcp - XDiff;
                xmax = xcp + XDiff;
            end

            XLim = [xmin xmax];
        else,
            XLim = [xcp - XDiff, xcp + XDiff];
        end
    end

    %
    % Set new Xlimits.
    % NOTE: Check that the limits aren't equal.  This happens
    %   at very small limits.  In this case, we do nothing.
    %
    if abs(XLim(1) - XLim(2)) > 1e-10*(abs(XLim(1)) + abs(XLim(2))),
        for i=1:zoomStruct.AXnum,
            set(AxisList(i), 'XLim', XLim);
            simscope('ResizeHiLites',fig);
        end
    else,
        warning('Axis limits cannot be zoomed any further!');
    end

case 'yonly',
    %
    % y only zoom.
    % RBBOX - lines (only 1-3 used):
    %    2
    %  --o--  
    %    |
    %  1 |
    %    |
    %  -----           
    %    3
    %

    %
    % Determine the end point of zoom operation.
    %

    %
    % End pt is the 2nd point of line 1.
    %
    YDat = get(hLines(1), 'YDat');
    ycp = YDat(2);

    %
    % Clip to current axes.
    %
    if ycp > currentYLim(2),
        ycp = currentYLim(2);
    end
    if ycp < currentYLim(1),
        ycp = currentYLim(1);
    end

    endPt = [origen(1) ycp];

    %
    % Determine mode: POINT or RBBOX.
    %
    if ycp == origen(2),
        bPointMode = 1;
    else,
        bPointMode = 0;
    end

    %
    % Determine the new limits.
    %
    if (bPointMode == 0),
        %
        % Bounding Box Mode.
        %

        %
        % Calculate new Y Limits
        %
        YLim = [endPt(2) origen(2)];
        if YLim(1) > YLim(2),
            YLim = YLim([2 1]);
        end
    else,
        %
        % Point Mode.
        %

        %
        % Divide the vertical into 5 divisions.
        %
        YLim = get(cAx, 'YLim'); YDiff = (YLim(2) - YLim(1)) / 5;
        if strcmp(get(cAx, 'YScale'), 'log'),
            % YLim(1) must be >= 1

            candidateYMin = ycp - YDiff;
            if candidateYMin < 1,
                ymin = 1;
                delta = 1 - candidateYMin;
                ymax = ycp + YDiff + delta;
            else,
                ymin = ycp - YDiff;
                ymax = ycp + YDiff;
            end

            YLim = [ymin ymax];
        else,  
            YLim = [ycp - YDiff, ycp + YDiff];
        end
    end

    %
    % Set new Ylimits.
    % NOTE: Check that the limits aren't equal.  This happens
    %   at very small limits.  In this case, we do nothing.
    %
    if abs(YLim(1) - YLim(2)) > 1e-10*(abs(YLim(1)) + abs(YLim(2))),
        set(cAx, 'YLim', YLim);
        simscope('ResizeHiLites',fig);
    else,
        warning('Axis limits cannot be zoomed any further!');
    end
end %switch

%
% Push old limits onto stack.
%
limits = [currentXLim currentYLim];
i_FastPushLimitsOntoStack(cAx, limits);

%
% Delete the RBBOX lines.
%
delete(hLines);

%
% Clear motion & up functions.
%
set(fig,'windowbuttonmotionfcn', '');
set(fig,'windowbuttonupfcn', '');


% Function =====================================================================
% Handle the zoom in actions.

function i_ZoomIn(ax, zoomUserStruct, zoomMode),

%
% Create the lines used for the rbbox.
% NOTE: All lines are initialize to contain 2 pts where both points
%       are located at the current point (i.e., zoom origen).
%
cp = get(ax, 'CurrentPoint'); cp = cp(1,1:2);
x  = ones(2,4) * cp(1);
y  = ones(2,4) * cp(2);

if get(0,'ScreenDepth') == 8,
  hLines = line(x,y, ...
    'Parent',           get(gcbf,'CurrentAxes'),...
    'Visible',          'on',...
    'EraseMode',        'xor',...
    'LineWidth',        2,...
    'Color',            'w',...
    'Tag',              '_TMWZoomLines');
else,
  hLines = line(x,y, ...
    'Parent',           get(gcbf,'CurrentAxes'),...
    'Visible',          'on',...
    'EraseMode',        'xor',...
    'Color',            [0.7 0.75 0.7],...
    'Tag',              '_TMWZoomLines');
end,

%
% Store the handles to the lines in the userdata.
%
zoomUserStruct.hLines = hLines;
    
%
% Set the motion and up fcn's.
%

%
% Set new one.
%
fig = get(ax, 'Parent');
set(fig, 'WindowButtonMotionFcn', ['scopezoom butmot ' zoomMode]);
set(fig, 'WindowButtonUpFcn', ['scopezoom butup ' zoomMode]);

%
% Update the axes user data.
%
updateZoomDataContainer(fig,zoomUserStruct);


% Function =====================================================================
% Put new limits onto stack.
% NOTE: No error checking is done.  It is assumed that zoomUserData exits,
%       and that the limits are valid.

function i_FastPushLimitsOntoStack(currentAxes, limits),

fig           = get(currentAxes, 'Parent');
zoomStruct    = getZoomDataContainer(fig);
AxisList      = getCurrentAxisList(fig);
scopeUserData = getScopeUserData(fig);

%
% Add limits to stack.
%
zoomStruct.topOfStack = zoomStruct.topOfStack + 1;
for i=1:zoomStruct.AXnum,
    if  currentAxes == AxisList(i),
        zoomStruct.stack(i,zoomStruct.topOfStack,:) = limits;
    else
        zoomStruct.stack(i,zoomStruct.topOfStack,:) = ...
            [limits(1), limits(2), get(AxisList(i),'YLim')];
    end,
end,

%
% Updating Scope User Data
%
set(scopeUserData.axesContextMenu.zoomout,'Enable','on');
updateScopeUserData(fig,scopeUserData);

%
% Updating the Zoom Data Container
%
updateZoomDataContainer(fig,zoomStruct);


% Function =====================================================================
% Zoom out 1-level (pop zoom stack).

function i_ZoomOut1Level(ax),

fig        = get(ax, 'Parent');
zoomStruct = getZoomDataContainer(fig);
AxisList   = getCurrentAxisList(fig);

%
% Pop the stack & restore the limits.
%
if zoomStruct.topOfStack ~= 0,
    for i = 1:zoomStruct.AXnum,
        set(AxisList(i), ...                 
            'XLim', zoomStruct.stack(i,zoomStruct.topOfStack,1:2),...
            'YLim', zoomStruct.stack(i,zoomStruct.topOfStack,3:4));
    end
    zoomStruct.topOfStack = zoomStruct.topOfStack - 1;
    simscope('ResizeHiLites',fig);
end

%
% Disable Zoom Out on the context menu topOfStack == 0
%
if zoomStruct.topOfStack == 0,
    scopeUserData = getScopeUserData(fig);
    set(scopeUserData.axesContextMenu.zoomout,'Enable','off');
    updateScopeUserData(fig,scopeUserData);
end

%
% Update the axes user data.
%
updateZoomDataContainer(fig,zoomStruct);


% Function =====================================================================
% Based on specified zoomMode, sets the axis limits to auto.     ***

function i_SetLimsToAuto(ax, zoomMode),

switch(zoomMode),

case 'normal',
    set(ax, 'XLimMode', 'auto', 'YLimMode', 'auto');

case 'xonly',
    set(ax, 'XLimMode', 'auto');

case 'yonly',
    set(ax, 'YLimMode', 'auto');

otherwise,
    error('Invalid zoomMode.');
end


% Function =====================================================================
% Jump back to bottom of stack (i.e., return view to "original").

function i_ZoomToOriginalView(ax, zoomMode),

fig           = get(ax, 'Parent');
zoomStruct    = getZoomDataContainer(fig);
AxisList      = getCurrentAxisList(fig);
scopeUserData = getScopeUserData(fig);

%
% Restore original limits.
%
limits = zoomStruct.originalLimits;
for i = 1:zoomStruct.AXnum,
    set(AxisList(i), 'XLim', zoomStruct.originalLimits(i,1:2), ...
                     'YLim', zoomStruct.originalLimits(i,3:4));
end
simscope('ResizeHiLites',fig);

%
% Reset stack pointer to bottom (i.e., the stack is empty).
%
zoomStruct.topOfStack = 0;

%
% Set the WindowButtonUpFcn.
%

%
% Set new one.
%
fig = get(ax, 'Parent');
set(fig, 'WindowButtonUpFcn', ['scopezoom butupOut ' zoomMode]);

%
% Disable the Zoom Out Context Menu option
%
set(scopeUserData.axesContextMenu.zoomout,'Enable','off');

%
% Update the axes and the scope user data.
%
updateScopeUserData(fig,scopeUserData);
updateZoomDataContainer(fig,zoomStruct);


% Function =====================================================================
% Jump back to bottom of stack (i.e., return view to "original").

function i_RestoreToOriginalView(ax, zoomMode),

fig           = get(ax, 'Parent');
zoomStruct    = getZoomDataContainer(fig);
AxisList      = getCurrentAxisList(fig);
scopeUserData = getScopeUserData(fig);

%
% Restore original limits.
%
limits = zoomStruct.originalLimits;
for i = 1:zoomStruct.AXnum,
    set(AxisList(i), 'YLim', zoomStruct.originalLimits(i,3:4));
end
simscope('ResizeHiLites',fig);

%
% Reset stack pointer to bottom (i.e., the stack is empty).
%
zoomStruct.topOfStack = 0;

%
% Set the WindowButtonUpFcn.
%

%
% Set new one.
%
fig = get(ax, 'Parent');
set(fig, 'WindowButtonUpFcn', ['scopezoom butupOut ' zoomMode]);

%
% Disable the Zoom Out Context Menu option
%
set(scopeUserData.axesContextMenu.zoomout,'Enable','off');

%
% Update the axes and the scope user data.
%
updateScopeUserData(fig,scopeUserData);
updateZoomDataContainer(fig,zoomStruct);


% Function =====================================================================
% Execute buttonupfcn for right & double click.

function i_ZoomButtonUpOutFcn(fig),

zoomStruct = getZoomDataContainer(fig);

%
% Clear the windowbuttonupfcn.
%
set(fig, 'WindowButtonUpFcn', '');


% Function =====================================================================
% What is the zoom state? 
% NOTE: the 'off' state means that either the WindowButtonDownFcn is either
%  empy or not set to one of the zoom commands.                            

function zoomState = i_ZoomState(fig),

zoomCmd = get(fig, 'WindowButtonDownFcn');
str     = 'scopezoom';
if isempty(zoomCmd) | ~strcmp(zoomCmd(1:length(str)), str),
    zoomState = 'off';
else,
    k = max(find(zoomCmd == ' '));
    zoomState = zoomCmd(k+1:end);
end


% Function =====================================================================
% Enable Xonly Mode.  Called both for 'xon' and 'xonly'.

function i_EnableXonlyMode(fig),

zoomMode = 'xonly';
set(fig, 'WindowButtonDownFcn', ['scopezoom butdwn ' zoomMode]);


% Function =====================================================================
% Enable Yonly Mode.  Called both for 'yon' and 'yonly'.

function i_EnableYonlyMode(fig),

zoomMode = 'yonly';
set(fig, 'WindowButtonDownFcn', ['scopezoom butdwn ' zoomMode]);


% Function =====================================================================
% Zoom Off

function i_zoomOff(fig),

if strcmp(i_ZoomState(fig), 'off'),
    return;
end

set(fig, 'WindowButtonDownFcn', '');


% Function =====================================================================
% Resets the zoomUserStruct.

function i_ResetZoomState(fig),

if ~strcmp(i_ZoomState(fig), 'off'),
   zoomStruct    = getZoomDataContainer(fig);
   scopeUserData = getScopeUserData(fig);
   AxisList      = getCurrentAxisList(fig);

    %
    % Reset stack and orignal view.
    %
    zoomStruct.topOfStack = 0;
    for i=1:zoomStruct.AXnum,
        zoomStruct.originalLimits(i,:) = ...
        [get(AxisList(i), 'XLim'), get(AxisList(i), 'YLim')];
    end
          
    %
    % Disable Zoom Out on the Context Menu.
    %
    set(scopeUserData.axesContextMenu.zoomout,'Enable','off');
    updateZoomDataContainer(fig,zoomStruct);
end


% Function =====================================================================
% Returns the copy of the field: scopeUserData.zoomUserStruct.

function zoomUserStruct = getZoomDataContainer(scopeFig),

scopeUserData = get(scopeFig,'UserData');
eval('zoomUserStruct = scopeUserData.zoomUserStruct;',...
     'error(''zoomUserStruct field of Scope figure user data is missing'')');

% Function =====================================================================
% Updates the field: scopeUserData.zoomUserStruct

function updateZoomDataContainer(scopeFig,zoomUserStruct),

scopeUserData = get(scopeFig,'UserData');
scopeUserData.zoomUserStruct = zoomUserStruct;
set(scopeFig,'UserData',scopeUserData);


% Function =====================================================================
% Returns the copy of the scopeeUserData.

function scopeUserData = getScopeUserData(scopeFig),

scopeUserData = get(scopeFig,'UserData');


% Function =====================================================================
% Updates the scopeeUserData.

function updateScopeUserData(scopeFig,scopeUserData),

set(scopeFig,'UserData',scopeUserData);

% Function =====================================================================
% Returns the copy of the field: scopeUserData.scopeAxes.

function currentAxisList = getCurrentAxisList(scopeFig),

scopeUserData = get(scopeFig,'UserData');
eval('currentAxisList = scopeUserData.scopeAxes;',...
     'error(''scopeAxes field of the Scope figure user data is missing'')');

% [EOF] scopezoom.m
