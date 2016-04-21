function [hThis] = datacursormanager(hFig)

% Copyright 2003 The MathWorks, Inc.

hFig = handle(hFig);

hThis = graphics.datacursormanager;
set(hThis,'Figure',hFig);

localAddInternalListeners(hThis);

%-------------------------------------------------%
function localAddInternalListeners(hThis)
% setup listeners

l(1) = handle.listener(hThis,...
                       'ObjectBeingDestroyed',...
                       {@localDestroy,hThis});

l(end+1) = handle.listener(hThis,...
                           findprop(hThis,'SnapToDataVertex'),...
                           'PropertyPostSet',...
                           {@localSetSnapToDataVertex,hThis});

lorig = get(hThis,'InternalListeners');
set(hThis,'InternalListeners',[l,lorig]);

%-----------------------------------------------%
function localSetSnapToDataVertex(obj,evd,hTool)
% Update state of all data cursors

h = get(hTool,'DataCursors');
snapon = get(hTool,'SnapToDataVertex');
if strcmpi(snapon,'on')   
   set(h,'Interpolate','off');
else
   set(h,'Interpolate','on');
end

%-------------------------------------------------%
function localDestroy(obj,evd,hThis)

;