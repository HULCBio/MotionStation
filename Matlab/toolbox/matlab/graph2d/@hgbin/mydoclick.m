function cObj = mydoclick(cObj)
%HGBIN/MYDOCLICK Click for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:53 $

figH = gcbf;
selType = get(figH,'SelectionType');
figUnits = get(figH,'Units');

children = cObj.Contents;
selectRect = Pos2Rect(rbbox);

for i = 1:length(children)
   aChild = children{i};
   alreadySelected = get(aChild,'IsSelected');
   
   oldUnits = aChild.Units;
   aChild.Units = figUnits;
   aChildRect = Pos2Rect(aChild.Position);

   inSelection = InSelectRect(aChildRect,selectRect);

   switch selType
   case 'normal'
      if inSelection ~= alreadySelected
	 set(aChild,'IsSelected',inSelection);
      end
   case 'extend'
      if InSelectRect(aChildRect,selectRect)
	 set(aChild,'IsSelected',1);
      end
   otherwise
   end
   
   aChild.Units = oldUnits;
end


function rect = Pos2Rect(pos)
% POS2RECT Local function.
rect = pos + [0 0 pos(1:2)];


function val = InSelectRect(objRect, selectRect)
hits = ((objRect(1:2) >= selectRect(1:2)) & ...
	(objRect(3:4) <= selectRect(3:4))) | ...
       ((objRect(1:2) <= selectRect(1:2)) & ...
        (objRect(3:4) >= selectRect(3:4)));
if hits
   val = 1;
else
   val = 0;
end




