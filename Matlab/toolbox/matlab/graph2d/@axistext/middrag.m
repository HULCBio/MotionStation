function aObj = middrag(aObj)
%AXISTEXT/MIDDRAG Drag axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $   $Date: 2004/01/15 21:12:02 $

savedState = get(aObj,'SavedState');

if savedState.DataUnitDrag
   pointer = get(savedState.Ax, 'CurrentPoint');
else
   pointer = get(savedState.Fig, 'CurrentPoint');
end

pointX = pointer(1,1);
pointY = pointer(1,2);

aObj = domove(aObj,pointX,pointY);
