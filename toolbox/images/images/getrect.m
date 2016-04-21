function rect = getrect(varargin)
%GETRECT Select rectangle with mouse.
%   RECT = GETRECT(FIG) lets you select a rectangle in the
%   current axes of figure FIG using the mouse.  Use the mouse to
%   click and drag the desired rectangle.  RECT is a four-element
%   vector with the form [xmin ymin width height].  To constrain
%   the rectangle to be a square, use a shift- or right-click to
%   begin the drag.
%
%   RECT = GETRECT(AX) lets you select a rectangle in the axes
%   specified by the handle AX.
%
%   See also GETLINE, GETPTS.

%   Callback syntaxes:
%        getrect('ButtonDown')
%        getrect('ButtonMotion')
%        getrect('ButtonUp')

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.22.4.3 $  $Date: 2003/08/01 18:08:55 $

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

if ((nargin >= 1) & (ischar(varargin{1})))
    % Callback invocation: 'ButtonDown', 'ButtonMotion', or 'ButtonUp'
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETRECT_AX = gca;
    GETRECT_FIG = get(GETRECT_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        CleanGlobals;
        eid = 'Images:getrect:expectedHandle';
        error(eid, '%s', 'First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETRECT_FIG = varargin{1};
        GETRECT_AX = get(GETRECT_FIG, 'CurrentAxes');
        if (isempty(GETRECT_AX))
            GETRECT_AX = axes('Parent', GETRECT_FIG);
        end

    case 'axes'
        GETRECT_AX = varargin{1};
        GETRECT_FIG = get(GETRECT_AX, 'Parent');

    otherwise
        CleanGlobals;
        eid = 'Images:getrect:expectedFigureOrAxesHandle';
        error(eid, '%s', 'First argument should be a figure or axes handle');
    end
end

% Remember initial figure state
old_db = get(GETRECT_FIG, 'DoubleBuffer');
state = uisuspend(GETRECT_FIG);

% Set up initial callbacks for initial stage
set(GETRECT_FIG, ...
    'Pointer', 'crosshair', ...
    'WindowButtonDownFcn', 'getrect(''ButtonDown'');', ...
    'DoubleBuffer', 'on');

% Set axes limit modes to manual, so that the presence of lines used to
% draw the rectangles doesn't change the axes limits.
original_modes = get(GETRECT_AX, {'XLimMode', 'YLimMode', 'ZLimMode'});
set(GETRECT_AX,'XLimMode','manual', ...
               'YLimMode','manual', ...
               'ZLimMode','manual');

% Bring target figure forward
figure(GETRECT_FIG);

% Initialize the lines to be used for the drag
GETRECT_H1 = line('Parent', GETRECT_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'k', ...
                  'LineStyle', '-');

GETRECT_H2 = line('Parent', GETRECT_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'w', ...
                  'LineStyle', ':');


% We're ready; wait for the user to do the drag
% Wrap the waitfor call in try-catch so
% that if the user Ctrl-C's we get a chance to
% clean up the figure.
errCatch = 0;
try
    waitfor(GETRECT_H1, 'UserData', 'Completed');
catch
    errCatch = 1;
end

% After the waitfor, if GETRECT_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishandle(GETRECT_H1) | ...
            ~strcmp(get(GETRECT_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = get(GETRECT_H1, 'XData');
    y = get(GETRECT_H1, 'YData');
end

% Delete the animation objects
if (ishandle(GETRECT_H1))
    delete(GETRECT_H1);
end
if (ishandle(GETRECT_H2))
    delete(GETRECT_H2);
end

% Restore the figure state
if (ishandle(GETRECT_FIG))
   uirestore(state);
   set(GETRECT_FIG, 'DoubleBuffer', old_db);
   
   if ishandle(GETRECT_AX)
       set(GETRECT_AX, {'XLimMode','YLimMode','ZLimMode'}, original_modes);
   end
end

CleanGlobals;

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % Return the answer
    xmin = min(x);
    ymin = min(y);
    rect = [xmin ymin max(x)-xmin max(y)-ymin];
    
case 'trap'
    % An error was trapped during the waitfor
    eid = 'Images:getrect:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse selection.');
    
case 'unknown'
    % User did something to cause the rectangle drag to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the drag.
    eid = 'Images:getrect:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse selection.');
end

%--------------------------------------------------
% Subfunction ButtonDown
%--------------------------------------------------
function ButtonDown

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

set(GETRECT_FIG, 'Interruptible', 'off', ...
                 'BusyAction', 'cancel');

[x1, y1] = getcurpt(GETRECT_AX);
GETRECT_PT1 = [x1 y1];
GETRECT_TYPE = get(GETRECT_FIG, 'SelectionType');
x2 = x1;
y2 = y1;
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');

% Let the motion functions take over.
set(GETRECT_FIG, 'WindowButtonMotionFcn', 'getrect(''ButtonMotion'');', ...
                 'WindowButtonUpFcn', 'getrect(''ButtonUp'');');


%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

[x2,y2] = getcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata);

%--------------------------------------------------
% Subfunction ButtonUp
%--------------------------------------------------
function ButtonUp

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

% Kill the motion function and discard pending events
set(GETRECT_FIG, 'WindowButtonMotionFcn', '', ...
                 'Interruptible', 'off');

% Set final line data
[x2,y2] = getcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];
if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata);

% Unblock execution of the main routine
set(GETRECT_H1, 'UserData', 'Completed');

%-----------------------------------------------
% Subfunction Constrain
% 
% constrain rectangle to be a square in
% axes coordinates
%-----------------------------------------------
function [xdata_out, ydata_out] = Constrain(xdata, ydata)

x1 = xdata(1);
x2 = xdata(2);
y1 = ydata(1);
y2 = ydata(3);
ydis = abs(y2 - y1);
xdis = abs(x2 - x1);

if (ydis > xdis)
   x2 = x1 + sign(x2 - x1) * ydis;
else
   y2 = y1 + sign(y2 - y1) * xdis;
end

xdata_out = [x1 x2 x2 x1 x1];
ydata_out = [y1 y1 y2 y2 y1];

%---------------------------------------------------
% Subfunction CleanGlobals
%--------------------------------------------------
function CleanGlobals

% Clean up the global workspace
clear global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
clear global GETRECT_PT1 GETRECT_TYPE



