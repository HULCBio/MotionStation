function addconstr(Editor,Constr)
%ADDCONSTR  Add Root-Locus constraint to editor.

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 04:58:17 $

FreqUnitFlag = ~isempty(Constr.findprop('FrequencyUnits'));
LoopData = Editor.LoopData;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Initialize editor-specific properties
Constr.Ts = LoopData.Ts;
if FreqUnitFlag
	Constr.FrequencyUnits = Editor.FrequencyUnits;
end

% Add related listeners 
L = handle.listener(LoopData, LoopData.findprop('Ts'), ...
			     'PropertyPostSet', {@LocalUpdate,Constr});
if FreqUnitFlag
  L = [L ; handle.listener(Editor, Editor.findprop('FrequencyUnits'), ...
	       'PropertyPostSet', {@LocalUpdate,Constr})];
end
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor);


%-------------------- Local functions ---------------------------------

function LocalUpdate(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
set(Constr,eventSrc.Name,eventData.NewValue)
% Update constraint display (and notify observers)
update(Constr)
