function [cmin, cmax] = caxis(arg1, arg2)
%CAXIS  Pseudocolor axis scaling.
%   CAXIS(V), where V is the two element vector [cmin cmax], sets manual
%   scaling of pseudocolor for the SURFACE and PATCH objects created by
%   commands like MESH, PCOLOR, and SURF.  cmin and cmax are assigned
%   to the first and last colors in the current colormap.  Colors for PCOLOR
%   and SURF are determined by table lookup within this range.  Values
%   outside the range are clamped to the first or last colormap color.
%   CAXIS('manual') fixes axis scaling at the current range.
%   CAXIS('auto') sets axis scaling back to autoranging.
%   CAXIS, by itself, returns the two element row vector containing the
%   [cmin cmax] currently in effect.
%   CAXIS(AX,...) uses axes AX instead of the current axes.
%
%   CAXIS is an M-file that sets the axes properties CLim and CLimMode.
%
%   See also COLORMAP, AXES, AXIS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2002/04/15 04:28:31 $

arg = 0;
if (nargin == 0)
	ax = gca;
elseif isempty(arg1)
	if (ischar(arg1))
		arg = lower(arg1);
	else
		arg = arg1;
	end
elseif (ischar(arg1))|(length(arg1) > 1)
	% string input (check for valid option later)
	if nargin == 2
		error('First argument must be a scalar axes handle.')
	end
	ax = gca;
	if (ischar(arg1))
		arg = lower(arg1);
	else
		arg = arg1;
	end
else
	% handle must be a handle and axes handle
	if ~ishandle(arg1) | ~strcmp(get(arg1, 'type'), 'axes')
		error('First argument must be a scalar axes handle.');
	end
	ax = arg1;

	% check for string option
	if nargin == 2
		if (ischar(arg2))
			arg = lower(arg2);
		else
			arg = arg2;
		end
	end
end

if (isempty(arg))
	error('Must be two element row vector.')
end

if (arg == 0)
	cmin = get(ax,'CLim');
	if(nargout == 2)
		cmax = cmin(2); cmin = cmin(1);
	end
else
	if(isstr(arg))
		if(strcmp(arg, 'auto'))
			set(ax,'CLimMode','auto');
		elseif(strcmp(arg, 'manual'))
			set(ax,'CLimMode','manual');
		else
			error('Unknown command option')
		end
	else
		[r c] = size(arg);
		if(r * c == 2)
			set(ax,'CLim',arg);
		else
			error('Must be two element row vector.')
		end
	end
end
