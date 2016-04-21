function newA = copyobj(A, HGParent)
%AXISOBJ/COPYOBJ Copy axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/01/15 21:11:37 $

% call inherited copyobj
newA = A;
HGObj = newA.scribehgobj;
newA.scribehgobj = copyobj(HGObj, HGParent);

newHG = get(newA,'MyHGHandle');
% decouple the new axis from any legends on the original axes
% remove old legend delete proxy if one exists.
deleteProxy = findall(newHG,'Tag','LegendDeleteProxy');
if ~isempty(deleteProxy)
   set(deleteProxy,'DeleteFcn','');
   delete(deleteProxy);
end

% Unlock the axis position by default when pasting
% so the position is close to where the user clicks
% and so it's easier to move around.
newA = set(newA,'Draggable',1);

% update children
labels = get(newHG,{'Title' 'XLabel' 'YLabel' 'ZLabel'});
children = [ allchild(newHG)' [labels{:}]];

newFig = HGParent;
for aChild = children
   try
      aH = getobj(aChild);
      if ~isempty(aH)
         myUIContextMenu = getscribecontextmenu(aH.HGHandle);
         UIContextMenuTag = get(myUIContextMenu,'Tag');
         % update the HG references in the handle
         newObj = set(aH.Object,'MyHGHandle',aChild);
         newH = scribehandle(newObj);
         % update the context menu
         newUIContextMenu = findall(newFig,'Tag',UIContextMenuTag);
         if isempty(newUIContextMenu)
            newUIContextMenu = copyobj(myUIContextMenu,newFig);
         end
         if ~isempty(newUIContextMenu)
            setscribecontextmenu(aChild,newUIContextMenu(1));
         end
      end
   catch
      warning(['Error copying axes: ' lasterr]);
   end
end


