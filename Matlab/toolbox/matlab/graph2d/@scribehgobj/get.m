function val = get(A, varargin)
%SCRIBEHGOBJ/GET Get scribehgobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2004/01/15 21:13:28 $

narg = size(varargin);
if narg == 1
   val = getone(A,varargin{1});
else
   subs = varargin{1}{1};
   for idx = 1:length(subs)
      val{idx} = getone(A(subs(idx)),varargin{2:end});
   end
end


function val = getone(A,property)

switch property
case 'UIContextMenu'
   val = getscribecontextmenu(A.HGHandle);
   return
case 'IsSelected'
   val = A.ObjSelected;
   return
case 'Draggable'
   val = A.Draggable;
case 'DragConstraint'
   val = A.DragConstraint;
case 'SavedState'
   val = A.SavedState;
case 'MyHandle'
   try
      ud = getscribeobjectdata(A.HGHandle);
      val = ud.HandleStore;
   catch
      val = [];
      warning('Object is nonexistent or corrupted...');
   end
   return
case 'MyHGHandle'
   val = A.HGHandle;
case 'MyBin'
   val = A.ObjBin;
   if ~isempty(val) & iscell(val)
      val = val{:};
   end
   return
case 'NextItem'
   val = LGetItemI(A,+1);
case 'PrevItem'
   val = LGetItemI(A,-1);
case 'AllItems'
   myhandle = get(A,'myhandle');
   val = A.ObjBin;
   if ~isempty(val) & iscell(val)
      val = val{:};
      if isa(val,'hgbin')
         val = get(val,'items');
      else
         val = myhandle;
      end
   end
case 'OtherItems'
   val = A.ObjBin;
   if ~isempty(val) & iscell(val)
      val = val{:};
      if isa(val,'hgbin')
         siblings = get(val,'items');
         myhandle = get(A,'myhandle');
         val = siblings(find(siblings~=myhandle));
      else
         val = {};
      end
   end
otherwise
   val = get(A.HGHandle, property);
end


function val = LGetItemI(A, offset)

val = A.ObjBin;
if ~isempty(val) & iscell(val)
   val = val{:};
   if isa(val,'hgbin')
      siblings = get(val,'Items');
      myhandle = get(A,'MyHandle');
      iNextItem = find(siblings==myhandle) + offset;
      iNextItem = iNextItem(1);
      if iNextItem >= 1 & iNextItem <= length(siblings)
	 val = siblings(iNextItem);
      else
	 val = {};
      end
   else
      val = {};
   end
end

