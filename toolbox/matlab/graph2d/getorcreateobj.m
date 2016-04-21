function MLObj = getorcreateobj(co)
%GETORCREATEOBJ  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2002/05/25 13:32:08 $

MLObj = [];  %assign to empty initially to prevent unassigned variable warnings

ud = getscribeobjectdata(co);
if isempty(ud)
   obj = [];
   coTag = get(co,'Tag');
   if any(strmatch('ScribeArrowline',coTag)) | isa(co, 'graph2d.arrow')
      % this is an arrow whos data was blown away
      cbo = co;
      obj = set(arrowline(co),'Draggable',1);
      obj = set(obj,'DragConstraint','');
      co = get(obj,'MyHGHandle');
   else
      switch get(co,'Type')
      case 'axes'
         if ~strcmp(get(co,'Tag'),'legend')
             obj = set(axisobj(co),'Draggable',0);
         else
             obj = set(axisobj(co),'Draggable',0);
         end
     case 'line'
         axisHandle=ancestor(co,'Axes');
         axisTag = get(axisHandle,'Tag');
         axisClass = class(handle(axisHandle));
         
         if strcmp(axisTag,'legend')
             obj = set(editline(co),'Draggable',0);
         elseif (strcmp(axisTag,'ScribeOverlayAxesActive') | ...
                 strcmp(axisClass,'graph2d.annotationlayer'))
             obj = set(editline(co),'Draggable',1);
             obj = set(obj,'DragConstraint','');
         else
             obj = set(editline(co),'Draggable',0);
         end
      case 'text'
         if strcmp(get(ancestor(co,'Axes'),'Tag'),'legend')      
            obj = set(axistext(co),'Draggable',0);
        else
            obj = set(axistext(co),'Draggable',1);
         end
     case 'figure'
         obj=figobj(co);
     case {'root','uimenu','uicontrol'}
         %NOOP   
     otherwise % patch, surface, rectangle, image, other
         if ~isempty(ancestor(co,'axes'))
             obj = set(axischild(co),'Draggable',0);
         else
             %noop
         end
     end
 end
   if ~isempty(obj)
      p = scribehandle(obj);
      ud = getscribeobjectdata(co);
      MLObj = ud.ObjectStore;
   else
      return
   end
else
   MLObj = ud.ObjectStore;
end
