function varargout = getline(varargin)
%GETLINE Select polyline with mouse.
%   [X,Y] = GETLINE(FIG) lets you select a polyline in the
%   current axes of figure FIG using the mouse.  Coordinates of
%   the polyline are returned in X and Y.  Use normal button
%   clicks to add points to the polyline.  A shift-, right-, or
%   double-click adds a final point and ends the polyline
%   selection.  Pressing RETURN or ENTER ends the polyline
%   selection without adding a final point.  Pressing BACKSPACE
%   or DELETE removes the previously selected point from the
%   polyline.
%
%   [X,Y] = GETLINE(AX) lets you select a polyline in the axes
%   specified by the handle AX.
%
%   [X,Y] = GETLINE is the same as [X,Y] = GETLINE(GCF).
%
%   [X,Y] = GETLINE(...,'closed') animates and returns a closed
%   polygon.
%
%   See also GETRECT, GETPTS.

%   Callback syntaxes:
%        getline('KeyPress')
%        getline('FirstButtonDown')
%        getline('NextButtonDown')
%        getline('ButtonMotion')

%   Grandfathered syntaxes:
%   XY = GETLINE(...) returns output as M-by-2 array; first
%   column is X; second column is Y.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.27.4.2 $  $Date: 2003/08/01 18:08:53 $

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y
global GETLINE_ISCLOSED

xlimorigmode = xlim('mode');
ylimorigmode = ylim('mode');
xlim('manual');
ylim('manual');

if ((nargin >= 1) & (isstr(varargin{end})))
    str = varargin{end};
    if (str(1) == 'c')
        % getline(..., 'closed')
        GETLINE_ISCLOSED = 1;
        varargin = varargin(1:end-1);
    end
else
    GETLINE_ISCLOSED = 0;
end

if ((length(varargin) >= 1) & isstr(varargin{1}))
    % Callback invocation: 'KeyPress', 'FirstButtonDown',
    % 'NextButtonDown', or 'ButtonMotion'.
    feval(varargin{:});
    return;
end

GETLINE_X = [];
GETLINE_Y = [];

if (length(varargin) < 1)
    GETLINE_AX = gca;
    GETLINE_FIG = get(GETLINE_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        CleanUp(xlimorigmode,ylimorigmode);
        eid = 'Images:getline:expectedHandle';
        error(eid, '%s', 'First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETLINE_FIG = varargin{1};
        GETLINE_AX = get(GETLINE_FIG, 'CurrentAxes');
        if (isempty(GETLINE_AX))
            GETLINE_AX = axes('Parent', GETLINE_FIG);
        end

    case 'axes'
        GETLINE_AX = varargin{1};
        GETLINE_FIG = get(GETLINE_AX, 'Parent');

    otherwise
        CleanUp(xlimorigmode,ylimorigmode);
        eid = 'Images:getline:expectedFigureOrAxesHandle';
        error(eid, '%s', 'First argument should be a figure or axes handle');
    end
end

% Remember initial figure state
old_db = get(GETLINE_FIG, 'DoubleBuffer');
state= uisuspend(GETLINE_FIG);

% Set up initial callbacks for initial stage
set(GETLINE_FIG, ...
    'Pointer', 'crosshair', ...
    'WindowButtonDownFcn', 'getline(''FirstButtonDown'');',...
    'KeyPressFcn', 'getline(''KeyPress'');', ...
    'DoubleBuffer', 'on');

% Bring target figure forward
figure(GETLINE_FIG);

% Initialize the lines to be used for the drag
GETLINE_H1 = line('Parent', GETLINE_AX, ...
                  'XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'k', ...
                  'LineStyle', '-');

GETLINE_H2 = line('Parent', GETLINE_AX, ...
                  'XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'w', ...
                  'LineStyle', ':');

% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in try-catch so we'll
% have a chance to clean up after ourselves.
errCatch = 0;
try
    waitfor(GETLINE_H1, 'UserData', 'Completed');
catch
    errCatch = 1;
end

% After the waitfor, if GETLINE_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishandle(GETLINE_H1) | ...
            ~strcmp(get(GETLINE_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = GETLINE_X(:);
    y = GETLINE_Y(:);
    % If no points were selected, return rectangular empties.
    % This makes it easier to handle degenerate cases in
    % functions that call getline.
    if (isempty(x))
        x = zeros(0,1);
    end
    if (isempty(y))
        y = zeros(0,1);
    end
end

% Delete the animation objects
if (ishandle(GETLINE_H1))
    delete(GETLINE_H1);
end
if (ishandle(GETLINE_H2))
    delete(GETLINE_H2);
end

% Restore the figure's initial state
if (ishandle(GETLINE_FIG))
   uirestore(state);
   set(GETLINE_FIG, 'DoubleBuffer', old_db);
end

CleanUp(xlimorigmode,ylimorigmode);

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % Return the answer
    if (nargout >= 2)
        varargout{1} = x;
        varargout{2} = y;
    else
        % Grandfathered output syntax
        varargout{1} = [x(:) y(:)];
    end
    
case 'trap'
    % An error was trapped during the waitfor
    eid = 'Images:getline:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse selection.');
    
case 'unknown'
    % User did something to cause the polyline selection to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the middle of the selection.
    eid = 'Images:getline:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse selection.');
end

%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_PT1 
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

key = get(GETLINE_FIG, 'CurrentCharacter');
switch key
case {char(8), char(127)}  % delete and backspace keys
    % remove the previously selected point
    switch length(GETLINE_X)
    case 0
        % nothing to do
    case 1
        GETLINE_X = [];
        GETLINE_Y = [];
        % remove point and start over
        set([GETLINE_H1 GETLINE_H2], ...
                'XData', GETLINE_X, ...
                'YData', GETLINE_Y);
        set(GETLINE_FIG, 'WindowButtonDownFcn', ...
                'getline(''FirstButtonDown'');', ...
                'WindowButtonMotionFcn', '');
    otherwise
        % remove last point
        if (GETLINE_ISCLOSED)
            GETLINE_X(end-1) = [];
            GETLINE_Y(end-1) = [];
        else
            GETLINE_X(end) = [];
            GETLINE_Y(end) = [];
        end
        set([GETLINE_H1 GETLINE_H2], ...
                'XData', GETLINE_X, ...
                'YData', GETLINE_Y);
    end
    
case {char(13), char(3)}   % enter and return keys
    % return control to line after waitfor
    set(GETLINE_H1, 'UserData', 'Completed');     

end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

[x,y] = getcurpt(GETLINE_AX);

% check if GETLINE_X,GETLINE_Y is inside of axis
xlim = get(GETLINE_AX,'xlim');
ylim = get(GETLINE_AX,'ylim');
if (x>=xlim(1)) & (x<=xlim(2)) & (y>=ylim(1)) & (y<=ylim(2))
    % inside axis limits
    GETLINE_X = x;
    GETLINE_Y = y;
else
    % outside axis limits, ignore this FirstButtonDown
    return
end

if (GETLINE_ISCLOSED)
    GETLINE_X = [GETLINE_X GETLINE_X];
    GETLINE_Y = [GETLINE_Y GETLINE_Y];
end

set([GETLINE_H1 GETLINE_H2], ...
        'XData', GETLINE_X, ...
        'YData', GETLINE_Y, ...
        'Visible', 'on');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETLINE_H1, 'UserData', 'Completed');
else
    % Let the motion functions take over.
    set(GETLINE_FIG, 'WindowButtonMotionFcn', 'getline(''ButtonMotion'');', ...
            'WindowButtonDownFcn', 'getline(''NextButtonDown'');');
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

selectionType = get(GETLINE_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
    % We don't want to add a point on the second click
    % of a double-click

    [x,y] = getcurpt(GETLINE_AX);
    if (GETLINE_ISCLOSED)
        GETLINE_X = [GETLINE_X(1:end-1) x GETLINE_X(end)];
        GETLINE_Y = [GETLINE_Y(1:end-1) y GETLINE_Y(end)];
    else
        GETLINE_X = [GETLINE_X x];
        GETLINE_Y = [GETLINE_Y y];
    end
    
    set([GETLINE_H1 GETLINE_H2], 'XData', GETLINE_X, ...
            'YData', GETLINE_Y);
    
end

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETLINE_H1, 'UserData', 'Completed');
end

%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

[newx, newy] = getcurpt(GETLINE_AX);
if (GETLINE_ISCLOSED & (length(GETLINE_X) >= 3))
    x = [GETLINE_X(1:end-1) newx GETLINE_X(end)];
    y = [GETLINE_Y(1:end-1) newy GETLINE_Y(end)];
else
    x = [GETLINE_X newx];
    y = [GETLINE_Y newy];
end

set([GETLINE_H1 GETLINE_H2], 'XData', x, 'YData', y);

%---------------------------------------------------
% Subfunction CleanUp
%--------------------------------------------------
function CleanUp(xlimmode,ylimmode)

xlim(xlimmode);
ylim(ylimmode);
% Clean up the global workspace
clear global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
clear global GETLINE_X GETLINE_Y
clear global GETLINE_ISCLOSED
