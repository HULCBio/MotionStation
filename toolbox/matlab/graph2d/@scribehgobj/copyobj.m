function newObj = copyobj(hgObj,HGParent)
%SCRIBEHGOBJ/COPYOBJ Copy scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2004/01/15 21:13:21 $

% call the get method so overloads (figobj/get) have chance...
HG = get(hgObj,'MyHGHandle');

try
   myUIContextMenu = getscribecontextmenu(HG);
   UIContextMenuTag = get(myUIContextMenu,'Tag');
   newHG = copyobj(HG,HGParent);
   % the object SHOULD copied implicitly through the appdata
   % (but at the moment is is not)
   UD = getscribeobjectdata(HG);
   setscribeobjectdata(newHG,UD);
   
   % but not the contextmenu...
   parentType = get(HGParent,'Type');
   switch parentType
   case 'axes'
      newFig = get(HGParent,'Parent');
   case 'figure'
      newFig = HGParent;
   end
   
   newUIContextMenu = findobj(allchild(newFig),'flat',...
           'Tag',UIContextMenuTag);
   if isempty(newUIContextMenu)
      newUIContextMenu = copyobj(myUIContextMenu,newFig);
   end
   if ~isempty(newUIContextMenu)
      setscribecontextmenu(newHG,newUIContextMenu(1));
   end
   % return a copy...
   newObj = set(hgObj,'MyHGHandle',newHG);
   
catch
   newObj = [];
end   

