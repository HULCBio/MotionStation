function aObj = domove(aObj, pointX, pointY, refresh)
%AXISCHILD/DOMOVE Do axischild move
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:11:27 $


savedState = get(aObj, 'SavedState');

X = get(aObj,'XData');
Y = get(aObj,'YData');

switch get(aObj,'DragConstraint')
case ''
   aObj = set(aObj,...
	   'XData',X + (pointX-X(1) - savedState.OffsetX),...
	   'YData',Y + (pointY-Y(1) - savedState.OffsetY));
case 'fixX'
   aObj = set(aObj,'YData',Y + (pointY-Y(1) - savedState.OffsetY));
case 'fixY'
   aObj = set(aObj,'XData',X + (pointX-X(1) - ...
	   savedState.OffsetX));
end


