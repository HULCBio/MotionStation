function A = set(A, varargin)
%SCRIBEHGOBJ/SET Set scribehgobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.18.4.1 $  $Date: 2004/01/15 21:13:31 $

if nargin > 1
   arg1 = varargin{1};
   if isa(arg1,'char') & nargin == 3
      switch varargin{1}
      case 'SavedState'
	 A.SavedState = varargin{2};
	 return
      case 'ObjBin'
         A.ObjBin = varargin{2};
         return
      case 'IsSelected'
         A.ObjSelected = varargin{2};
         myH = get(A,'MyHandle');
         figH = get(myH,'Figure');
         figObjH = getobj(figH);
         if ~isempty(figObjH)
            dragBinH = figObjH.DragObjects;
            currentSelection = dragBinH.Items;
            if varargin{2}
               if isempty(currentSelection) | ~any(currentSelection==myH)
                  set(A,'Selected','on');
                  dragBinH.NewItem = myH;
               end
            else
               if ~isempty(currentSelection) & any(currentSelection==myH)   
                  set(A,'Selected','off');
                  dragBinH.RemoveItem = myH;
               end
            end
         end
         return
      case 'Draggable'
         A.Draggable = varargin{2};
         return
      case 'DragConstraint'
         A.DragConstraint = varargin{2};
         return
      case 'MyHGHandle'
         A.HGHandle = varargin{2};
         return
      end
      HGObj = A.HGHandle;
      set(HGObj, varargin{:});
   end

   if isa(arg1,'cell')
      property = varargin{2};
      values = varargin{3};
      if ~isa(values,'cell')
         values = {values};
      end
      for idx = 1:length(arg1{1})
         B = A(arg1{1}(idx));
         B = set(B,property,values{idx});
      end
   else
      HGObj = A.HGHandle;
      set(HGObj,varargin{:})
   end
else
   HGObj = A.HGHandle;
   set(HGObj);	
end




