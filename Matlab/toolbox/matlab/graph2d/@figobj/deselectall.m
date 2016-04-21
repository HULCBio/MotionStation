function figObj = deselectall(figObj)
%FIGOBJ/DESELECTALL Deselect all for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2004/01/15 21:12:33 $

dragBin = figObj.DragObjects;
if ~isempty(dragBin.Items)
    for aObjH = fliplr(dragBin.Items);
        set(aObjH,'IsSelected',0);
    end
end