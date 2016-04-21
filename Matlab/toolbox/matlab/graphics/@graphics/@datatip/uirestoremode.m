function uirestoremode(hThis,hFig)

% Copyright 2003 The MathWorks, Inc.

if ~isempty(hThis.uistate)
   set(hFig,'WindowButtonMotionFcn',hThis.uistate.WindowButtonMotionFcn); 
   set(hFig,'WindowButtonUpFcn',hThis.uistate.WindowButtonUpFcn);
   set(hFig,'Pointer',hThis.uistate.Pointer);
end