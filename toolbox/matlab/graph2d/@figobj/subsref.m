function B = subsref(A,S)
%FIGOBJ/SUBSREF Subscripted reference for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:42 $

switch S.type
case '.'
   switch lower(S.subs)
   case 'hghandle'
      B = get(A,'HGHandle');
   case 'myhghandle'
      B = get(A,'MyHGHandle');
   case 'notes'
      B = A.Notes;
   case 'date'
      B = A.Date;
   case 'origin'
      B = A.Origin;
   case 'savedposition'
      B = A.SavedPosition;
   case 'dragobjects'
      B = A.DragObjects;
   otherwise
      hgObj = A.scribehgobj;
      B = subsref(hgObj,S);
   end
end
