function B = subsref(A,S)
%AXISOBJ/SUBSREF Subscript reference for axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:11:50 $

switch S.type
case '.'
   switch S.subs
   case 'FigObj'
      B = A.FigObj;
   case 'Notes'
      B = A.Notes;
   otherwise
      HGObj = A.scribehgobj;
      B = subsref(HGObj,S);
   end
end
