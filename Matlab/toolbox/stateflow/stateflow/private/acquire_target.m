function newTarget = acquire_target(machineNameOrId,targetName)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:55:57 $
	
if(ischar(machineNameOrId))
   machineId = sf('find','all','machine.name',machineNameOrId);
else
   machineId = machineNameOrId;
end
targets = sf('TargetsOf',machineId);
newTarget = sf('find',targets,'target.name',targetName);
if(~isempty(newTarget))
   return;
end

%%% doesnt exist: create new one.
newTarget = new_target(machineId,targetName);

