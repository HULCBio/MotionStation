function g=savecursor(g,updateundo)
%SAVECURSOR saves state of cursor for later restoration

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:02 $

if nargin<2
   updateundo=logical(1);
end

if ~strcmp(get(g.h.fig,'Pointer'),'watch')
   g.ref.Pointer=get(g.h.fig,'Pointer');
   set(g.h.fig,'Pointer','watch')
      
   if updateundo
      g.s.ref.changed=logical(1);
      
      %set up "undo" information
      undoBuffer=undobuffer(g.s);
      maxundo=get(undoBuffer,'UserData');
      savedHandles=get(undoBuffer,'children');
      if length(savedHandles)>=maxundo
         delete(savedHandles(maxundo:end));
      end
      
      newUndo=uimenu('parent',undoBuffer,...
         'label',LocMakeLabel,...
         'UserData',get(g.s,'UserData'));
      mainChild=children(g.s);
      copyobj(mainChild.h,newUndo);
                  
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function menuLabel=LocMakeLabel

currTime=clock;
menuLabel=sprintf('Undo %s:%s:%s', num2str(currTime(4)) , ...
      num2str(currTime(5)) , ...
      num2str(currTime(6)));