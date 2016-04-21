function cObj = subsasgn(cObj, S, B)
%HGBIN/SUBSASGN Subscripted assignment for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:12:55 $

switch S(1).type
case '.'
   switch S(1).subs
   case 'ResetParent'
      cObj.ResetParent = B;
   case 'NewItem'
      if ~isa(B,'scribehandle')
         B = get(B,'MyHandle');
      end
      cObj = InsertItemAtI(cObj, B, cObj.InsertPt);
   case 'RemoveItem'
      if ~isa(B,'scribehandle')
         B = get(B,'MyHandle');
      end
      others = validatehandles(cObj.Items);
      if isempty(others)
         cObj.Items = others;
      else
         cObj.Items = others(find(others ~= B));
      end
   case 'Items'
      cObj.Items = B;
      cObjH = get(cObj,'MyHandle');
      for i = 1:length(B);
	     theItem = SetBin(B(i), cObjH);
      end
   otherwise
      theHGobj = cObj.scribehgobj;
      cObj.scribehgobj = subsasgn(theHGobj, S, B);
   end
otherwise
   theHGobj = cObj.scribehgobj;
   cObj.scribehgobj = subsasgn(theHGobj, S, B);
end


function cObj = InsertItemAtI(cObj, anItem, I)
if isa(anItem,'cell')
   anItem = anItem{:};
end

contents = cObj.Items;
cObjH = get(cObj,'MyHandle');

itemObjH = SetBin(anItem, cObjH);

if ~isempty(contents)
   if I < 0
      contents = [contents itemObjH];
   elseif I == 0
      contents = [itemObjH contents];
   else
      contents = [contents(0:I) itemObjH contents(I+1:end)];
   end
else
   contents = itemObjH;
end
cObj.Items = contents;



function itemObjH = SetBin(anItem, cObjH)

if isa(anItem,'scribehandle')
   if cObjH.ResetParent
      set(anItem,'ObjBin', {cObjH});   % standard version
   end
   itemObjH = anItem;
elseif isa(anItem,'scribehgobj')
   if cObjH.ResetParent
      anItem = set(anItem,'ObjBin', {cObjH});  % writeback version
   end
   itemObjH = get(anItem,'MyHandle');
end
