function aObj = enddrag(aObj)
%AXISTEXT/ENDDRAG End axistext drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:12:00 $

savedState = get(aObj,'SavedState');
if ~savedState.DataUnitDrag
   aObj = set(aObj,'Units',savedState.OldUnits);
end

axischildObj = aObj.axischild;
aObj.axischild = enddrag(axischildObj);

