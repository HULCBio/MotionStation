function map = colormap(arg1,arg2)
%COLORMAP Color look-up table.
%   COLORMAP(MAP) sets the current figure's colormap to MAP.
%   COLORMAP('default') sets the current figure's colormap to
%   the root's default, whose setting is JET.
%   MAP = COLORMAP retrieves the current colormap. The values
%   are in the range from 0 to 1.
%   COLORMAP(AX,...) uses the figure corresponding to axes AX
%   instead of the current figure.
%
%   A color map matrix may have any number of rows, but it must have
%   exactly 3 columns.  Each row is interpreted as a color, with the
%   first element specifying the intensity of red light, the second 
%   green, and the third blue.  Color intensity can be specified on the
%   interval 0.0 to 1.0.
%   For example, [0 0 0] is black, [1 1 1] is white, 
%   [1 0 0] is pure red, [.5 .5 .5] is gray, and
%   [127/255 1 212/255] is aquamarine.
%   
%   Graphics objects that use pseudocolor  -- SURFACE and PATCH objects,
%   which are created by the functions MESH, SURF, and PCOLOR -- map
%   a color matrix, C, whose values are in the range [Cmin, Cmax],
%   to an array of indices, k, in the range [1, m].
%   The values of Cmin and Cmax are either min(min(C)) and max(max(C)),
%   or are specified by CAXIS.  The mapping is linear, with Cmin
%   mapping to index 1 and Cmax mapping to index m.  The indices are
%   then used with the colormap to determine the color associated
%   with each matrix element.  See CAXIS for details.
% 
%   Type HELP GRAPH3D to see a number of useful colormaps.
%
%   COLORMAP is an M-file that sets the Colormap property of a figure.
%
%   See also HSV, CAXIS, SPINMAP, BRIGHTEN, RGBPLOT, FIGURE, COLORMAPEDITOR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.21.4.2 $  $Date: 2004/04/10 23:26:47 $

arg = 0;
if (nargin == 0)
	figH = gcf;
elseif (ischar(arg1))|(length(arg1) > 1)|isempty(arg1)
	% string input (check for valid option later)
	if (nargin == 2)
		error('First argument must be a scalar axes handle.')
	end
	figH = gcf;
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
	figH = ancestor(ax,'figure');
	
	% check for string option
	if nargin == 2
		if (ischar(arg2))
			arg = lower(arg2);
		else
			arg = arg2;
		end
	end
end

if isequal(arg,0)
    map = get(figH, 'Colormap');
	return
end
if isstr(arg)
	if strcmp(arg,'default')
		set(figH,'Colormap','default');
		return
	end
	k = min(findstr(arg,'('));
	if ~isempty(k)
		arg = feval(arg(1:k-1),str2double(arg(k+1:end-1)));
	else
		arg = feval(arg);
	end
end
if ~isempty(arg)
	if (size(arg,2) ~= 3)
		error('Colormap must have 3 columns: [R,G,B].');
	end
	if min(min(arg)) < 0 | max(max(arg)) > 1
		error('Colormap must have values in [0,1].')
	end
end
set(figH, 'Colormap', arg);
if nargout == 1
	map = get(figH, 'Colormap');
end
