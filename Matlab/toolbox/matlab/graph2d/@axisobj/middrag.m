function aObj = middrag(aObj)
%AXISOBJ/MIDDRAG Drag axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $   $Date: 2004/01/15 21:11:45 $

savedState = get(aObj,'SavedState');
pointer = get(savedState.Fig, 'CurrentPoint');

aObj = domove(aObj,pointer(1),pointer(2));
