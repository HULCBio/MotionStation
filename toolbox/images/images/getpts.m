function [x,y] = getpts(varargin)
%GETPTS Select points with mouse.
%   [X,Y] = GETPTS(FIG) lets you choose a set of points in the
%   current axes of figure FIG using the mouse. Coordinates of
%   the selected points are returned in the vectors X and Y. Use
%   normal button clicks to add points.  A shift-, right-, or 
%   double-click adds a final point and ends the selection.  
%   Pressing RETURN or ENTER ends the selection without adding 
%   a final point.  Pressing BACKSPACE or DELETE removes the 
%   previously selected point.
%
%   [X,Y] = GETPTS(AX) lets you choose points in the axes
%   specified by the handle AX.
%
%   [X,Y] = GETPTS is the same as [X,Y] = GETPTS(GCF).
%
%   See also GETRECT, GETLINE.

%   Callback syntaxes:
%       getpts('KeyPress')
%       getpts('FirstButtonDown')
%       getpts('NextButtonDown')

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.22.4.2 $  $Date: 2003/08/01 18:08:54 $

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2
global GETPTS_PT1 

if ((nargin >= 1) & (isstr(varargin{1})))
    % Callback invocation: 'KeyPress', 'FirstButtonDown', or 
    % 'NextButtonDown'.
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETPTS_AX = gca;
    GETPTS_FIG = get(GETPTS_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        eid = 'Images:getpts:expectedHandle';
        error(eid, '%s', 'First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETPTS_FIG = varargin{1};
        GETPTS_AX = get(GETPTS_FIG, 'CurrentAxes');
        if (isempty(GETPTS_AX))
            GETPTS_AX = axes('Parent', GETPTS_FIG);
        end

    case 'axes'
        GETPTS_AX = varargin{1};
        GETPTS_FIG = get(GETPTS_AX, 'Parent');

    otherwise
        eid = 'Images:getpts:expectedFigureOrAxesHandle';
        error(eid, '%s', 'First argument should be a figure or axes handle');

    end
end

% Bring target figure forward
figure(GETPTS_FIG);

% Remember initial figure state
state = uisuspend(GETPTS_FIG);

% Set up initial callbacks for initial stage
[pointerShape, pointerHotSpot] = CreatePointer;
set(GETPTS_FIG, 'WindowButtonDownFcn', 'getpts(''FirstButtonDown'');', ...
        'KeyPressFcn', 'getpts(''KeyPress'');', ...
        'Pointer', 'custom', ...
        'PointerShapeCData', pointerShape, ...
        'PointerShapeHotSpot', pointerHotSpot);

% Initialize the lines to be used for the drag
markerSize = 9;
GETPTS_H1 = line('Parent', GETPTS_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'c', ...
                  'LineStyle', 'none', ...
                  'Marker', '+', ...
                  'MarkerSize', markerSize, ...
                  'EraseMode', 'xor');

GETPTS_H2 = line('Parent', GETPTS_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'm', ...
                  'LineStyle', 'none', ...
                  'Marker', 'x', ...
                  'MarkerSize', markerSize, ...
                  'EraseMode', 'xor');

% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in try-catch so we'll
% have a chance to clean up after ourselves.
errCatch = 0;
try
   waitfor(GETPTS_H1, 'UserData', 'Completed');
catch
   errCatch=1;
end

% After the waitfor, if GETPTS_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishandle(GETPTS_H1) | ...
            ~strcmp(get(GETPTS_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H1, 'YData');
    x = x(:);
    y = y(:);
    % If no points were selected, return rectangular empties.
    % This makes it easier to handle degenerate cases in
    % functions that call getpts.
    if (isempty(x))
        x = zeros(0,1);
    end
    if (isempty(y))
        y = zeros(0,1);
    end
end

% Delete the animation objects
if (ishandle(GETPTS_H1))
    delete(GETPTS_H1);
end
if (ishandle(GETPTS_H2))
    delete(GETPTS_H2);
end

% Restore the figure state
if (ishandle(GETPTS_FIG))
    uirestore(state);
end

% Clean up the global workspace
clear global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2
clear global GETPTS_PT1 

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % No action needed.
    
case 'trap'
    % An error was trapped during the waitfor
    eid = 'Images:getpts:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse point selection.');
    
case 'unknown'
    % User did something to cause the point selection to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the middle of the selection.
    eid = 'Images:getpts:interruptedMouseSelection';
    error(eid, '%s', 'Interruption during mouse point selection.');
end


%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2
global GETPTS_PT1 

key = get(GETPTS_FIG, 'CurrentCharacter');
switch key
case {char(8), char(127)}  % delete and backspace keys
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H1, 'YData');
    switch length(x)
    case 0
        % nothing to do
    case 1
        % remove point and start over
        set([GETPTS_H1 GETPTS_H2], ...
                'XData', [], ...
                'YData', []);
        set(GETPTS_FIG, 'WindowButtonDownFcn', ...
                'getpts(''FirstButtonDown'');');
    otherwise
        % remove last point
        set([GETPTS_H1 GETPTS_H2], ...
                'XData', x(1:end-1), ...
                'YData', y(1:end-1));
    end

case {char(13), char(3)}   % enter and return keys
    % return control to line after waitfor
    set(GETPTS_H1, 'UserData', 'Completed');

end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2

[x,y] = getcurpt(GETPTS_AX);

set([GETPTS_H1 GETPTS_H2], ...
        'XData', x, ...
        'YData', y, ...
        'Visible', 'on');

if (~strcmp(get(GETPTS_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETPTS_H1, 'UserData', 'Completed');
else
    set(GETPTS_FIG, 'WindowButtonDownFcn', 'getpts(''NextButtonDown'');');
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2

selectionType = get(GETPTS_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
    % We don't want to add a point on the second click
    % of a double-click

    [newx, newy] = getcurpt(GETPTS_AX);
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H2, 'YData');

    set([GETPTS_H1 GETPTS_H2], 'XData', [x newx], ...
            'YData', [y newy]);
    
end

if (~strcmp(get(GETPTS_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETPTS_H1, 'UserData', 'Completed');
end



%----------------------------------------------------
% Subfunction CreatePointer
%----------------------------------------------------
function [pointerShape, pointerHotSpot] = CreatePointer

pointerHotSpot = [8 8];
pointerShape = [ ...
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
              1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
              2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
              2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
              1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];

        
