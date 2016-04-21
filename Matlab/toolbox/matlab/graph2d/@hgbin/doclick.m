function cObj = doclick(cObj)
%HGBIN/DOCLICK Click for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:49 $

cObj = doselect(cObj);
figH = gcbf;
selType = get(figH,'SelectionType');
figUnits = get(figH,'Units');

items = cObj.Items;
selectRect = Pos2Rect(rbbox);

for idx = 1:length(items)
   anItem = items{idx};
   alreadySelected = get(anItem,'IsSelected');
   
   oldUnits = anItem.Units;
   anItem.Units = figUnits;
   anItemRect = Pos2Rect(anItem.Position);

   inSelection = InSelectRect(anItemRect,selectRect);

   switch selType
   case 'normal'
      if inSelection ~= alreadySelected
         set(anItem,'IsSelected',inSelection);
      end
   case 'extend'
      if InSelectRect(anItemRect,selectRect)
         set(anItem,'IsSelected',1);
      end
   otherwise
   end
   
   anItem.Units = oldUnits;
end


function rect = Pos2Rect(pos)
% POS2RECT Local function.
rect = pos + [0 0 pos(1:2)];


function hits = InSelectRect(objRect, selectRect)
hits = ((objRect(1:2) >= selectRect(1:2)) & ...
        (objRect(3:4) <= selectRect(3:4))) | ...
       ((objRect(1:2) <= selectRect(1:2)) & ...
        (objRect(3:4) >= selectRect(3:4)));

