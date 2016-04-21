function addListeners(h)
% This function adds UDD listeners to the uibuttongroup object to
% internally manage the child components' state.

% Copyright 2003 The MathWorks, Inc.

listeners = get(h, 'Listeners');

listeners{end+1} = handle.listener(h, 'ObjectChildAdded', @childAddedCbk);
listeners{end+1} = handle.listener(h, 'ObjectChildRemoved', @childRemovedCbk);
listeners{end+1} = handle.listener(h, findprop(h, 'SelectedObject'), ...
    'PropertyPostSet', @selectionChangedCbk);
listeners{end+1} = handle.listener(h, 'ObjectBeingDestroyed', ...
    @objectDestroyedCbk);

set(h,'Listeners', listeners);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectionChangedCbk(src, evd)

% Throw the SelectionChanged Event.
hThis = evd.AffectedObject;
hEvent = handle.EventData(hThis, 'SelectionChanged');
send(hThis, 'SelectionChanged', hEvent);
