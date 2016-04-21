function down = startDrag(hThis,hFig)

% Copyright 2003-2004 The MathWorks, Inc.

if nargout,
    down = @localMarkerButtonDownFcn;
else
    localMarkerButtonDownFcn(hThis.MarkerHandle,[],hThis,hFig);
end

%-------------------------------------------------%
function localMarkerButtonDownFcn(eventSrc,eventData,hThis,hFig)
% This gets called when the user clicks on the datatip
% marker (not to be confused with the datatip textbox)

if ~ishandle(hThis)
  return;
end

sel_type = get(hFig,'SelectionType');

switch sel_type
   case 'normal' % left click
     % Move scribe text box in front of all other annotations
     
     % Place the datatip in selection mode so that the user can
     % drag     
   case 'open' % double click
     % do nothing
     return;
   case 'alt' % right click
     % do nothing
    return;
   case 'extend' % center click
     % do nothing
    return;
end

% Don't allow the datatip to drag
if strcmp(hThis.Draggable,'off')
  return;
end
  
% User may drag datatip, listen to window motion fcn until
% they click up
uistate = uiclearmode(hThis,hFig);
hThis.uistate = uistate;

% Swap in new callbacks
set(hFig,'WindowButtonMotionFcn',{@localMarkerMotionFcn,hThis});
set(hFig,'WindowButtonUpFcn',{@localMarkerButtonUpFcn,hThis});
set(hFig,'Pointer','fleur'); 

% Set to double buffer to avoid flickering
hThis.OriginalDoubleBufferState = get(hFig,'DoubleBuffer');
set(hFig,'DoubleBuffer','on'); 

% Highlite datatip
highlite(hThis,'on');

% Bring datatip to foreground
movetofront(hThis);

set(hThis,'DoThrowStartDragEvent',true);

%-------------------------------------------------%
function localMarkerMotionFcn(hMarker,evd,hThis)
% This gets called while the user mouse drags the 
% datatip marker around.

if ~ishandle(hThis) || ~strcmp(hThis.Visible,'on')
    return;
end

% If the user disabled the draggable property during the
% drag then we need to uninstall the callbacks
if strcmp(get(hThis,'Draggable'),'off')
  localMarkerButtonUpFcn(hMarker,[],hThis)
  return;
end

if get(hThis,'DoThrowStartDragEvent')

   % Throw BeginDrag event
   hEvent = handle.EventData(hThis,'BeginDrag');
   send(hThis,'BeginDrag',hEvent);

   % Notify behavior object
   hHost = get(hThis,'Host');
   hb = hggetbehavior(hHost,'DataCursor','-peek');
   if ~isempty(hb)
      fcn = get(hb,'StartDragFcn');
      if ~isempty(fcn)
         feval(fcn,hHost); 
      end
   end
   set(hThis,'DoThrowStartDragEvent',false);
end

% Update datatip position and string
update(hThis);

%-------------------------------------------------%
function localMarkerButtonUpFcn(hMarker,evd,hThis)
% This gets called when the user mouse clicks up 
% after dragging the datatip marker around.

if ~ishandle(hThis)
    return;
end

hFig = ancestor(getaxes(hThis),'figure');

% Restore figure uistate
uirestoremode(hThis,hFig);
hThis.uistate = [];

% Restore doublebuffer property
set(hFig,'doublebuffer',hThis.OriginalDoubleBufferState); 
  
   
% Throw EndDrag event 
hEvent = handle.EventData(hThis,'EndDrag');
send(hThis,'EndDrag',hEvent);

% Notify behavior object
hHost = get(hThis,'Host');
hb = hggetbehavior(hHost,'DataCursor','-peek');
if ~isempty(hb)
   fcn = get(hb,'EndDragFcn');
   if ~isempty(fcn)
      feval(fcn,hHost); 
   end
end

% Highlite datatip
highlite(hThis,'off');
