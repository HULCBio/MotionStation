function A = resize(A)
%AXISOBJ/RESIZE Resize axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2004/01/15 21:11:46 $

ax = get(A,'MyHGHandle');
f = get(A,'Parent');

[hitx, hity] = LHittest(ax,f);

if isempty(hitx) | isempty(hity)
   A = doclick(A);
else
   oldPtr = get(f,'Pointer');
   oldPos = get(ax,'Position');
   try
      figObjH = getobj(f);
      dragBinH = figObjH.DragObjects;
      myH = get(A, 'MyHandle');
      for aObjH = dragBinH.Items
         if ~(aObjH == myH)
            set(aObjH,'IsSelected',0);
         end
      end
      
      hitx=hitx(1);
      hity=hity(1);
      cursors = {'topl' 'top' 'topr'; ...
                 'left' '' 'right'; ...
                 'botl' 'bottom' 'botr' };...
              set(f,'Pointer',cursors{hity,hitx});
      result = selectmoveresize;
      set(f,'Pointer',oldPtr);
      val = 1;
   catch
      set(ax,'Position',oldPos);
      set(f,'Pointer',oldPtr);
   end
end





function [hitx, hity] = LHittest(ax,f)
% do my hit test to see if we've hit a selection handle
oldUnits = get([ax f],'Units');
set([ax f],'Units','pixels');
pos = get(ax,'Position');
pt = get(f,'CurrentPoint');
set([ax f],{'Units'},oldUnits);

x = pt(1);
y = pt(2);

handlesx = [...
           pos(1)   pos(1)+pos(3)/2-3  pos(1)+pos(3)-5 ;
           pos(1)+5 pos(1)+pos(3)/2+3  pos(1)+pos(3)];

handlesy = [...
           pos(2)+pos(4)-5 pos(2)+pos(4)/2-3  pos(2);
           pos(2)+pos(4)   pos(2)+pos(4)/2+3  pos(2)+5];
        
hitx = find( x>=handlesx(1,:) & x<=handlesx(2,:) );
hity = find( y>=handlesy(1,:) & y<=handlesy(2,:) );



