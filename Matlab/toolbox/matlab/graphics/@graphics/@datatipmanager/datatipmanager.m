function [hThis] = datatipmanager(hFig)

% Copyright 2002-2003 The MathWorks, Inc.

hFig = handle(hFig);

hThis = graphics.datatipmanager;

hThis.Figure = hFig;

localAddListeners(hThis);


%-------------------------------------------------%
function localAddListeners(hThis)
% setup listeners

l(1) = handle.listener(hThis,findprop(hThis,'CurrentDatatip'),...
                     'PropertyPostSet', {@localSetCurrentDatatip});

l(end+1) = handle.listener(hThis,'ObjectBeingDestroyed',...
    {@localDestroy,hThis});

l(end+1) = handle.listener(hThis.Figure,'ObjectBeingDestroyed',...
    {@localDestroy,hThis});

l(end+1) = handle.listener(hThis,'UpdateDatatip',...
    {@localUpdateDatatip,hThis});

hThis.Listeners = l;

%-------------------------------------------------%
function localSetCurrentDatatip(obj,evd)

% Defensive programming: Make sure current 
% datatip is in our list
hCurrentDatatip = evd.NewValue;
hDatatipManager = evd.AffectedObject;

if isempty(hCurrentDatatip)
  return;
end

if ~any(hCurrentDatatip==get(hDatatipManager,'DatatipHandles'))
  error('Invalid Current Datatip')
end

%-------------------------------------------------%
function localDestroy(obj,evd,hDatatipManager)

% Destory all handle references
removeAllDatatips(hDatatipManager);
delete(hDatatipManager.Listeners);
hDatatipManager.Figure = [];

%-------------------------------------------------%
function localUpdateDatatip(obj,evd,hDatatipManager)

set(hDatatipManager,'CurrentDatatip',evd.Datatip);
