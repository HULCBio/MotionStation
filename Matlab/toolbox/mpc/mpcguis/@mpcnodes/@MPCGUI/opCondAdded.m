function opCondAdded(mpcnode,opCondNode)

% Copyright 2003-2004 The MathWorks, Inc.

% Callback to operating condition node childadded/childremoved listener
% which updates the combo box in the linearization dialog

% If necessary build MPC GUI panel
if isempty(mpcnode.Linearization)
    mpcnode.getDialogSchema
end

% Delete existing node label listeners
mpcnode.Listeners(ismember(mpcnode.Listeners,find(mpcnode.listeners,'Callback', ...
{@localSyncLinearizeCombo, mpcnode, opCondNode}))) = [];

% (re)build op cond node name listeners
opnodes = opCondNode.getChildren;
mpcnode.addListeners(handle.listener(opnodes,opnodes(1).findprop('Label'), ...
    'PropertyPostSet',{@localSyncLinearizeCombo, mpcnode, opCondNode}));

% Execute listener
localSyncLinearizeCombo([],[], mpcnode, opCondNode);

function localSyncLinearizeCombo(eventData, eventSrc, mpcnode, opCondNode)

% Assign operating cond nodes to linearization combo
mpcnode.Linearization.LinearizationDialog.setOpCond(get(opCondNode.getChildren,{'Label'}));