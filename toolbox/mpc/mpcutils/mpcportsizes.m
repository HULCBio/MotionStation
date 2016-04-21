function [nmo,nmv,nr,nmd,inwidth] = mpcportsizes(blockname)

%% If necessary comile the model
if strcmp(get_param(gcs, 'SimulationStatus'),'stopped')
    feval(gcs,[],[],[],'compile');
end

%% MPC block port sizes and the total width of all linearization inputs
%% which are not attached to the MPC MO port

%% Get the number of i/os
ports = get_param(blockname, 'PortHandles');
nmv = get(ports.Outport,'compiledportwidth');
nr = get(ports.Inport(2),'compiledportwidth');
% If MD port is disconnected mnd = 0
if length(ports.Inport)>=3 && get(ports.Inport(3),'Line')~=-1
    nmd = get(ports.Inport(3),'compiledportwidth');
else
    nmd = 0;
end
nmo = get(ports.Inport(1),'compiledportwidth');

%% Count the width of open loop input i/os which are not MVs 
ioobj = getlinio(get_param(blockname,'Parent'));
inwidth = 0;
for k=1:length(ioobj)
    if strcmp(ioobj(k).Type,'in') && strcmp(ioobj(k).Active,'on') && ...
            ~strcmp(ioobj(k).Block,blockname) 
       ports1 = get_param(ioobj(k).Block, 'PortHandles');
       inwidth = inwidth+get(ports1.Outport(ioobj(k).PortNumber),'compiledportwidth');
    end
end

%% Stop the model
if ~strcmp(get_param(gcs, 'SimulationStatus'),'stopped')
    feval(gcs,[],[],[],'term');
end
