function newA = copyobj(A, HGParent)
%ARROWLINE/COPYOBJ Copy arrowline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:11:20 $

try
   newA = A;
   newA.editline = copyobj(newA.editline,HGParent);
   newA.fullline = get(newA,'MyHGHandle');

   C = copyobj([A.arrowhead A.line], HGParent);
   newA.arrowhead = C(1);
   newA.line = C(2);
   
   newUIContextMenu = get(newA.fullline,'UIContextMenu');
   set([newA.arrowhead newA.line], ...
           'UIContextMenu',newUIContextMenu);

   ad = getappdata(A.arrowhead,'ScribeArrowData');
   ad{1} = newA.line;
   ad{4} = newA.fullline;
   setappdata(newA.arrowhead, 'ScribeArrowData', ad);
   setappdata(newA.arrowhead, 'ScribeButtonDownHGObj', newA.fullline);
   setappdata(newA.line,'ScribeButtonDownHGObj',newA.fullline);
   set([newA.arrowhead, newA.line, newA.fullline],...
           'UserData',sprintf('%d',newA.fullline));
catch
   error('error copying arrowline')
end
