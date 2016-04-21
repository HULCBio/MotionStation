function s = evalStates(this, model, names)
% EVALSTATES Evalutes model states.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:03 $

% Create return structure
s = struct('Block', names, 'Value', [], 'Ts', []);

% State vector names from sizes call
[sys, x0, x0_str, ts, x0_ts] = feval(model, [], [], [], 'sizes');

for ct = 1:length(names)
  block  = names{ct};
  hBlock = getBlockHandle(this, block);

  % Is this a SimMechanics block instead of a regular one?
  isPhysical = any( strcmp( hBlock.fieldnames, 'PhysicalDomain' ) );
  
  if ~isPhysical
    idxs = strcmp( block, x0_str );
    if any(idxs)
      s(ct).Value  = x0(idxs);
      Ts           = x0_ts( idxs, 1 );
      s(ct).Ts     = Ts(1);
    else
      error('The block ''%s'' does not have states.', block)
    end
  else
    Manager = mech_stateVectorMgr( block );
    BlockStates = find( Manager.BlockStates, 'BlockName', block );
    
    if ~isempty(BlockStates)
      % REM: s(ct) may get its state values from multiple blocks
      s(ct).Value  = LocalGetSimMechStates( Manager, BlockStates );
      s(ct).Ts     = 0;
    else
      error('The block ''%s'' does not have states.', block)
    end
  end
end

% ----------------------------------------------------------------------------- %
function value = LocalGetSimMechStates(Manager, BlockStates)
value = [];

for ct = 1:length(BlockStates)
  % Find states with "partial" state name matching
  PartialStateName = [ BlockStates(ct).BlockName, ':', BlockStates(ct).Primitive ];
  idxs = strncmp(PartialStateName, Manager.StateNames, length(PartialStateName));
  
  % Store block/state info
  value = [ value; Manager.X(idxs)' ];
end
