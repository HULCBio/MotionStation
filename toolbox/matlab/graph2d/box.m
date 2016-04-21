function box(arg1, arg2);
%BOX    Axis box.
%   BOX ON adds a box to the current axes.
%   BOX OFF takes if off.
%   BOX, by itself, toggles the box state of the current axes.
%   BOX(AX,...) uses axes AX instead of the current axes.
%
%   BOX sets the Box property of an axes.
%
%   See also GRID, AXES.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:08:01 $

% To ensure the correct current handle is taken in all situations.

opt_box = 0;
if nargin == 0
	ax = gca;
else
	if isempty(arg1)
		opt_box = lower(arg1);
	end
	if ischar(arg1)
		% string input (check for valid option later)
		if nargin == 2
			error('First argument must be an axes handle.')
		end
		ax = gca;
		opt_box = lower(arg1);
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
			opt_box = lower(arg2);
		end
	end
end

if (isempty(opt_box))
	error('Unknown command option.');
end

if (opt_box == 0)
	if (strcmp(get(ax,'Box'),'off'))
		set(ax,'Box','on');
	else
		set(ax,'Box','off');
	end
elseif (strcmp(opt_box, 'on'))
	set(ax,'Box', 'on');
elseif (strcmp(opt_box, 'off'))
	set(ax,'Box', 'off');
else
	error('Unknown command option.');
end
