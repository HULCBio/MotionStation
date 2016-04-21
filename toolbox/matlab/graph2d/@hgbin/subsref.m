function B = subsref(cObj, S)
%HGBIN/SUBSREF Subscripted reference for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:56 $

switch S(1).type
case '.'
   switch lower(S(1).subs)
   case 'resetparent'
      B = cObj.ResetParent;
   case 'items'
      B = validatehandles(cObj.Items);
      cObj.Items = B;
      if (length(S)>1)
         B = subsref(B,S(2:end));
      end
   case 'scribehgobj'
      if (length(S)>1)
         B = subsref(cObj.scribehgobj,S(2:end));
      end
   otherwise
      theHGobj = cObj.scribehgobj;
      B = subsref(theHGobj, S);
   end
otherwise
   theHGobj = cObj.scribehgobj;
   B = subsref(theHGobj, S);
end

