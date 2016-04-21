function status = clean_target(machineId,targetName,objectsOnly)
% status = clean_target(machineId/machineName,targetName)

% Copyright 2003 The MathWorks, Inc.

if(nargin<3)
    objectsOnly = 0;
end

if(objectsOnly)
    cleanMethod = 'clean_objects';
else
    cleanMethod = 'clean';
end
[machineId,machineName] = unpack_machine_id(machineId);

% the library links may not be uptodate. must do find_system
machine_bind_sflinks(machineId,1);

targetId = acquire_target(machineId,targetName);
status = targetman(cleanMethod,targetId,0,0, targetId,[],machineId,0);

if(~sf('get',machineId,'machine.isLibrary'))
    linkMachines = get_link_machine_list(machineName,targetName);
    for i=1:length(linkMachines)
        linkMachineId = sf_force_open_machine(linkMachines{i});
        linkMachineTargetId = acquire_target(linkMachineId,targetName);
        status = targetman(cleanMethod,linkMachineTargetId,0,0, linkMachineTargetId,[],machineId,i);
    end
end
