function hh=gtext(string,varargin)
%GTEXT  Place text with mouse.
%   GTEXT('string') displays the graph window, puts up a
%   cross-hair, and waits for a mouse button or keyboard key to be
%   pressed.  The cross-hair can be positioned with the mouse (or
%   with the arrow keys on some computers).  Pressing a mouse button
%   or any key writes the text string onto the graph at the selected
%   location.  
%
%   GTEXT(C) places the multi-line strings defined by each row
%   of the cell array of strings C.
%
%   GTEXT(...,'PropertyName',PropertyValue,...) sets the value of
%   the specified text property.  Multiple property values can be set
%   with a single statement.
%
%   Example
%      gtext({'This is the first line','This is the second line'})
%      gtext({'First line','Second line'},'FontName','Times','Fontsize',12)
%
%   See also TEXT, GINPUT.

%   L. Shure, 12-01-88.
%   Revised: Charles D. Packard 3-8-89
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.14 $  $Date: 2002/04/15 04:07:45 $

if nargin == 0
   error('Not enough input arguments.');
end
if rem(nargin,2)~=1,
   error('Property value pairs expected.')
end  
if ~isstr(string) & ~iscellstr(string)
   error('Argument must be a string.')
end
[az el] = view;
if az ~= 0 | el ~= 90
   error('View must be two-dimensional.')
end
[r,c]=size(string);

h = [];
units = get(gca,'defaulttextunits');
set(gca,'defaulttextunits','data')
try
	for rows=1:r
		[x,y] = ginput(1);
		ht = text(x,y,string(rows,:),'VerticalAlignment','baseline',...
			'units',units,varargin{:});
		h = [ht; h];
	end
catch
	if (findstr(lasterr, 'Interrupted'))
		error('Interrupted');
	else
		error(lasterr);
	end
end
set(gca,'defaulttextunits',units)
if nargout > 0
   hh = h;
end
