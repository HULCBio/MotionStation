function cutcopypaste(currentFig,action)
%CUTCOPYPASTE  for Scribe Plot Editor

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 04:05:27 $

%Register this action with undo
%jpropeditutils('jundo','start',currentFig);

switch action
case 'cut'
   cutcopypaste(currentFig,'copy');
   LClearSelection(currentFig);
   return
   
case 'copy'
   [copyBufferFig, copyBufferAx] = getcopybuffer;
   % erase current copy buffer
      
   LClearSelection(copyBufferFig);
   selectionList = LGetSelection(currentFig);
   % scan for axes
   axesHandles = [];
   for aObjH = selectionList
      if strcmp(get(aObjH,'Type'),'axes')
         axesHandles(end+1)=get(aObjH,'MyHGHandle');
      end
   end
   % remove children of those axes from the selection list
   if ~isempty(axesHandles)
      for aObjH = selectionList
         if any(get(aObjH,'Parent')==axesHandles)
            set(aObjH,'IsSelected',0);
         end
      end
   end
   
   
   % store new selection
   initialPosition = get(currentFig,'CurrentPoint');
   for aObjH = LGetSelection(currentFig)
      objType = get(aObjH,'Type');
      switch objType
      case 'axes'
         set(aObjH,'Offset',initialPosition);
         newAH = copyobj(aObjH, copyBufferFig);
      case 'text'
         oldUnits = get(aObjH,'Units');
         % offset according to position relative to figure,
         % rather than position relative to parent axis
         set(aObjH,'Units','normalized');
         set(aObjH,'FigureOffset',initialPosition);
         newAH = copyobj(aObjH, copyBufferAx);
         set(aObjH,'Units',oldUnits);
      otherwise
         set(aObjH,'Offset',initialPosition);
         newAH = copyobj(aObjH, copyBufferAx);
         if LIsDataObj(aObjH)
            LMarkAsDataObj(newAH);
         end
      end
   end
   
   return
case 'paste'
   [copyBufferFig, copyBufferAx] = getcopybuffer;   
   % paste into current window from copy buffer
   
   axH=findall(currentFig,'type','axes');
   if ~isempty(axH)
       overlayAx=double(find(handle(axH),'-class','graph2d.annotationlayer'));
       if isempty(overlayAx)
           overlayAx = findall(axH,'Tag','ScribeOverlayAxesActive');
       end
   else
       overlayAx=[];
   end
       
   currentAx = get(currentFig,'CurrentAxes');
   fCreateDataAxes = isempty(currentAx);

   if isempty(overlayAx)
      warning('Could not paste into the current figure');
      return
   end
   
   for aObjH = LGetSelection(currentFig)
      set(aObjH,'IsSelected',0);
   end
   
   oldFigUnits = get(currentFig,'Units');
   newPt = get(overlayAx,'CurrentPoint');
   newX = newPt(1,1);
   newY = newPt(1,2);
   for aObjH = LGetSelection(copyBufferFig)
      if LIsAxisObj(aObjH)
         newAH = copyobj(aObjH, currentFig);
         if get(newAH,'Draggable')
            objectUnits = get(newAH,'Units');
            set(currentFig,'Units',objectUnits);
            newFigPt = get(currentFig,'CurrentPoint');
            domove(newAH,newFigPt(1),newFigPt(2),'refresh');
         end
      else
         if LIsMarkedDataObj(aObjH)
            if fCreateDataAxes
               currentAx = axes('Parent',currentFig);
               fCreateDataAxes = 0;
            end
            newAH = copyobj(aObjH, currentAx);
         else
            % annotations
            % offset and copy in
            newAH = copyobj(aObjH, overlayAx);
            domove(newAH,newX,newY,'refresh');
         end
      end
   end
   set(currentFig,'Units',oldFigUnits);

   promoteoverlay(currentFig);

   return
case 'clear'
   % clear current selection
   LClearSelection(currentFig);
end

%close undo transaction
%jpropeditutils('jundo','stop',currentFig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = LIsAxisObj(aObjH)
val = strcmp(get(aObjH,'Type'),'axes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = LIsDataObj(aObjH)

axH=get(get(aObjH,'MyHGHandle'),'Parent');

if isa(handle(axH),'graph2d.annotationlayer')
    val=0;
else
    val=~strcmp(get(axH,'tag'),'ScribeOverlayAxesActive');
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = LIsMarkedDataObj(aObjH)
% Temporary test: replace this with an explicit object
% property
fDataObj = getappdata(get(aObjH,'MyHGHandle'),'ScribeDataObj');
if isempty(fDataObj)
   val = 0;
else
   val = fDataObj;
end


function LMarkAsDataObj(aObjH)
setappdata(get(aObjH,'MyHGHandle'),'ScribeDataObj',1);



function LClearSelection(aFig)
% erase currently selected objects
aFigObjH = getobj(aFig);
if ~isempty(aFigObjH)
   dragBinH = aFigObjH.DragObjects;
   for aObjH = dragBinH.Items
      delete(aObjH);
   end
end


function objectVector = LGetSelection(aFig)
objectVector = [];
aFigObjH = getobj(aFig);
if ~isempty(aFigObjH)
   dragBinH = aFigObjH.DragObjects;
   objectVector = dragBinH.Items;
end

