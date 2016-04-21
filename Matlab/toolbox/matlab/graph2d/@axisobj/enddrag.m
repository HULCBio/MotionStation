function aObj = enddrag(aObj)
%AXISOBJ/ENDDRAG End axisobj drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/01/15 21:11:42 $

savedState = get(aObj, 'SavedState');
set(aObj,'Units',savedState.myOldUnits);


