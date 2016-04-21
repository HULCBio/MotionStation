function aObj = domove(aObj, pointX, pointY, refresh)
%EDITLINE/DOMOVE Move editline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:12:16 $

parentAxes = get(aObj,'Parent');
if ~(isa(handle(parentAxes),'graph2d.annotationlayer') | ...
        strcmp(get(parentAxes,'Tag'),'ScribeOverlayAxesActive'))
   return
end

savedState = get(aObj, 'SavedState');

X = get(aObj,'XData');
Y = get(aObj,'YData');

iPoints = savedState.iPoints;

X(iPoints) = X(iPoints) + (pointX-X(iPoints(1)) - savedState.OffsetX);
Y(iPoints) = Y(iPoints) + (pointY-Y(iPoints(1)) - savedState.OffsetY);

switch get(aObj,'DragConstraint')
case ''
   if nargin==3
      aObj = set(aObj, 'XYData',{X Y});
   else
      aObj = set(aObj, 'XYDataRefresh',{X Y});
   end
case 'fixX'
   aObj = set(aObj,'YData',Y);
case 'fixY'
   aObj = set(aObj,'XData',X);
% otherwise
%    no dragging allowed
end




