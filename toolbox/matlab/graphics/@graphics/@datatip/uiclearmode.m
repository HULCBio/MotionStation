function [uistate] = uiclearmode(hThis,hFig)

% Copyright 2003 The MathWorks, Inc.

uistate.WindowButtonMotionFcn = get(hFig,'WindowButtonMotionFcn');
uistate.WindowButtonUpFcn = get(hFig,'WindowButtonUpFcn');
uistate.Pointer = get(hFig,'Pointer');