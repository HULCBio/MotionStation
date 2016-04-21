function shiftwin(h)

%SHIFTWIN adjusts window position if corners are offscreen
%
%  SHIFTWIN(h) adjusts position of the window with handle h if any of 
%  the corners are offscreen.  The window is translated, but not scaled.


%  Written by:  W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $    $Date: 2004/02/01 21:59:05 $

% monitor characteristics

oldunits = get(0,'units');
set(0,'units','pixels');
screendim = get(0,'screensize');
set(0,'units',oldunits);



% window dimensions

oldunits = get(h,'units');
set(h,'units','pixels');
position = get(h,'position');


% shift window to get lower left corner on screen

llcornerx = position(1);
llcornery = position(2);

shiftx = llcornerx; if shiftx>0; shiftx=0; end
shifty = llcornery; if shifty>0; shifty=0; end

if shiftx<0 | shifty<0
	position = position + [-shiftx+50 -shifty+50 0 0];
	set(h,'position',position);
end

% shift window to get upper right hand corner on screen

urcornerx = position(1)+position(3);
urcornery = position(2)+position(4);

shiftx = urcornerx - screendim(3); if shiftx<0; shiftx=0; end
shifty = urcornery - screendim(4)+50; if shifty<0; shifty=0; end

if shiftx>0 
  position = position + [-shiftx-50 0 0 0];
	set(h,'position',position);
end
if shifty>0
	position = position + [0 -shifty-50 0 0];
	set(h,'position',position);
end
set(h,'units',oldunits);
