function grid(arg1, arg2);
%GRID   Grid lines.
%   GRID ON adds major grid lines to the current axes.
%   GRID OFF removes major and minor grid lines from the current axes. 
%   GRID MINOR toggles the minor grid lines of the current axes.
%   GRID, by itself, toggles the major grid lines of the current axes.
%   GRID(AX,...) uses axes AX instead of the current axes.
%
%   GRID sets the XGrid, YGrid, and ZGrid properties of
%   the current axes.
%
%   set(AX,'XMinorGrid','on') turns on the minor grid.
%
%   See also TITLE, XLABEL, YLABEL, ZLABEL, AXES, PLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.13 $  $Date: 2002/04/15 04:07:57 $

% To ensure the correct current handle is taken in all situations.

opt_grid = 0;
if nargin == 0
    ax = gca;
else
    if isempty(arg1)
        opt_grid = lower(arg1);
    end
    if ischar(arg1)
        % string input (check for valid option later)
        if nargin == 2
            error('First argument must be an axes handle.')
        end
        ax = gca;
        opt_grid = lower(arg1);
    else
        % make sure non string is a scalar handle
        if length(arg1) > 1
            error('Axes handle must be a scalar');
        end
        % handle must be a handle and axes handle
        if ~ishandle(arg1) | ~strcmp(get(arg1, 'type'), 'axes')
            error('First argument must be an axes handle.');
        end
        ax = arg1;
        
        % check for string option
        if nargin == 2
            opt_grid = lower(arg2);
        end
    end
end

if (isempty(opt_grid))
    error('Unknown command option.');
end

%---Check for bypass option
if isappdata(ax,'MWBYPASS_grid')
   mwbypass(ax,'MWBYPASS_grid',opt_grid);

elseif isequal(opt_grid, 0)
    if (strcmp(get(ax,'XGrid'),'off'))
        set(ax,'XGrid','on');
    else
        set(ax,'XGrid','off');
    end
    if (strcmp(get(ax,'YGrid'),'off'))
        set(ax,'YGrid','on');
    else
        set(ax,'YGrid','off');
    end
    if (strcmp(get(ax,'ZGrid'),'off'))
        set(ax,'ZGrid','on');
    else
        set(ax,'ZGrid','off');
    end
elseif (strcmp(opt_grid, 'minor'))
    if (strcmp(get(ax,'XMinorGrid'),'off'))
        set(ax,'XMinorGrid','on');
    else
        set(ax,'XMinorGrid','off');
    end
    if (strcmp(get(ax,'YMinorGrid'),'off'))
        set(ax,'YMinorGrid','on');
    else
        set(ax,'YMinorGrid','off');
    end
    if (strcmp(get(ax,'ZMinorGrid'),'off'))
        set(ax,'ZMinorGrid','on');
    else
        set(ax,'ZMinorGrid','off');
    end
elseif (strcmp(opt_grid, 'on'))
    set(ax,'XGrid', 'on', ...
           'YGrid', 'on', ...
           'ZGrid', 'on');
elseif (strcmp(opt_grid, 'off'))
    set(ax,'XGrid', 'off', ...
           'YGrid', 'off', ...
           'ZGrid', 'off', ...
           'XMinorGrid', 'off', ...
           'YMinorGrid', 'off', ...
           'ZMinorGrid', 'off');
else
    error('Unknown command option.');
end
