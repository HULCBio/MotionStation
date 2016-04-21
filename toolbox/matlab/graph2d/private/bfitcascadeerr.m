function [ed] = bfitcascadeerr(error, dlgtitle)
% BFITCASCADEERR(error, dlgtitle) will display an error box in a position slightly offset
% 	from the last error box displayed.

%   Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $

ds = findall(0, 'tag', 'bfiterrordlg');
ed = errordlg(error, dlgtitle);
set(ed, 'tag', 'bfiterrordlg');
if ~isempty(ds)
	saveunits = get(0, 'units');
	set(0, 'units', 'points');
	sc = get(0, 'ScreenSize');
	set(0, 'units', saveunits);
	set(ed, 'units', 'points');
	pos = get(ed, 'pos');
	lastpos = get(ds(1), 'pos');
	x = lastpos(1) + 15;
	y = lastpos(2) - 15;
	if ( ((x + pos(3)) > sc(3)) | (y < 60 ))
		x = 20;
		y = sc(4) - 60 - pos(4);
	end
	set(ed, 'pos', [x, y, pos(3), pos(4)]); 
end
