function doresize(HG)
%DORESIZE Calls figobj doresize function.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/15 04:07:49 $
%   J.H. Roh & B.A. Jones 5-22-97.

ud = getscribeobjectdata(HG);
if ~isempty(ud)
   obj = ud.ObjectStore;
   obj = doresize(obj);
   setscribeobjectdata(HG,ud);
else
   % probably here because the figure has been saved using
   % print -dmfile and reloaded.
   
   % create a new figobj object
   FH = scribehandle(figobj(HG));
   set(HG,'DoubleBuffer','on');
   
   % find the arrows and restore them
   arrowheads = findall(HG,'Tag','ScribeArrowlineHead');
   for anArrowHead = arrowheads'
      A = scribehandle(arrowline(anArrowHead));
      set(A,'Draggable',1);
      set(A,'DragConstraint','');
   end
   
   % resize
   doresize(FH);
   
end