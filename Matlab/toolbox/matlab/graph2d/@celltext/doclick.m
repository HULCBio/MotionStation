function A = doclick(A)
%CELLTEXT/DOCLICK Celltext mouse click
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:12:12 $


figH = get(A,'Figure');
figObjH = getobj(figH);
selType = figObjH.SelectionType;

selected = get(A,'IsSelected');

switch selType
case 'open'
   set(A,'Editing','on');
case 'normal'
   % select parent cell
   myCell = get(A,'MyBin');
   doclick(myCell);
case 'extend'
   % add to selection
end
   
