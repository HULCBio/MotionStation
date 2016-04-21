function addbodelisteners(Editor)
%ADDBODELISTENERS  Installs listeners for Bode editors.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $ $Date: 2002/04/10 04:56:33 $

% Add generic editor listeners (@grapheditor) 
Editor.addlisteners;

% Add Bode-specific listeners
Axes = Editor.Axes;
p = [Editor.findprop('MagVisible') ; Editor.findprop('PhaseVisible')];
ps = [Axes.findprop('XScale') ; Axes.findprop('YScale')];
L1 = [handle.listener(Editor,p,'PropertyPostSet',@hgset_visible);...
        handle.listener(Axes,ps,'PropertyPostSet',@update)];
set(L1,'CallbackTarget',Editor)

% Listener to changes in data units or transforms 
% (side effect = DataChanged event issued by @axesgroup)
L2 = handle.listener(Axes,'DataChanged',{@LocalPostSetUnits Editor});

Editor.Listeners = [Editor.Listeners ; L1 ; L2];


%-------------------- Callback functions -------------------


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalPostSetUnits %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPostSetUnits(hProp,eventdata,Editor)
% Called when changing units 
% Update labels
setlabels(Editor.Axes);

% Redraw plot 
update(Editor)