function figPos = figpos(figPos, units),
%FIGPOS	Ensure that the figure position fits within the confines of the screen.
%   onScreenPos = FIGPOS(figPos) returns a figure position that fits within
%   the confines of the screen.  If the desired position (input arg)
%   already fits on the screen, it is returned unaltered.  If the desired
%   position results in any part of the figure hanging off the screen, 
%   the figure is shifted such such that the portion of the figure that is
%   invisible just fits within the screen.  If the figure is to large for the
%   screen, it's left and top edges will be aligned with the left and top of
%   the screen.
%       
%   The figure width and height will not be altered.
%   This function assumes pixel units.  Alternate units may be specified via
%   the 2nd argument.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

if nargin ~= 2,
    units = 'pixel';
end

origRootUnits = get(0, 'Units');
set(0,'Units',units);
screensize = get(0, 'ScreenSize');
set(0,'Units',origRootUnits);

%
% Take best guess as to amount of space required for windows
%  title bar and menus (this guess applies to all platforms).
%

topWindowBorder    = 30;
bottomWindowBorder = 5;
sideWindowBorder   = 5;



topWindow    = figPos(2) + figPos(4) + topWindowBorder;
bottomWindow = figPos(2) - bottomWindowBorder;
rightWindow  = figPos(1) + figPos(3) + sideWindowBorder;
leftWindow   = figPos(1) - sideWindowBorder;
heightWindow = figPos(4) + topWindowBorder + bottomWindowBorder;
widthWindow  = figPos(3) + (sideWindowBorder * 2);


%==============================================================================
% Take care of vertical placement.
%==============================================================================

if  heightWindow > screensize(4)
  %
  % Figure height is greater than screen height, so we
  %  place top edge on top of screen so that the system menus
  %  are accessible.
  %
  
  deltaY = heightWindow - screensize(4);
  figPos(2) = 1 - deltaY;

elseif topWindow > screensize(4),
  %
  % Figure sticks out the top, move it down.
  %
 
  deltaY = (topWindow - screensize(4));
  figPos(2) = figPos(2) - deltaY;

elseif bottomWindow < 1,
  %
  % Figure sticks out the bottom, move it up.
  % (This shouldn't happen unless someone specified
  %  a negative pos(2))
  %
  
  deltaY = 1 - bottomWindow;
  figPos(2) = figPos(2) + deltaY;

end


%==============================================================================
% Take care of horizontal placement.
%==============================================================================

if widthWindow > screensize(3),
  %
  % Figure width is greater than screen width.  Place
  %  left edge on left of screen so that the system menu,
  %  is accessible.
  %
  
  figPos(1) = sideWindowBorder;

elseif rightWindow > screensize(3),
  %
  % Figure sticks out the right, move it left.
  %
 
  deltaX = (rightWindow - screensize(3));
  figPos(1) = figPos(1) - deltaX;

elseif leftWindow < 1,
  %
  % Figure sticks out the left, move it right.
  % (This shouldn't happen unless someone specifies
  %  a negative pos(1))
  %
  
  deltaX = 1 - leftWindow;
  figPos(1) = figPos(1) + deltaX;

end


