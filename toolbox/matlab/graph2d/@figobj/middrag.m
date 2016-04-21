function figObj = middrag(figObj)
%FIGOBJ/MIDDRAG Drag figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:39 $



dragBin = figObj.DragObjects;
for aObjH = dragBin.Items;
   middrag(aObjH);
end
