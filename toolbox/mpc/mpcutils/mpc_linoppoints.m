function op = mpc_linoppoints(blockname, modelname, u, y)
% MPC_LINOPPOINTS

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.

% Create an operating spec object for an MPC block based on the o/i
% constraints defnined by the third and forth arguments

%% Check that MV and MO ports are connected
op = [];
portcon = get_param(blockname, 'PortConnectivity');
mdportactive = double(strcmp(get_param(blockname,'md_inport'),'on'));
if isequal(portcon(1).SrcBlock,-1) || isequal(portcon(1).SrcBlock,-1) || ...
        length(portcon(3+mdportactive).DstBlock)==0
    msgbox('Both MV and MO ports must be connected. Cannot linearize', ...
        'MPC Toolbox','modal')
    return
end
    
%% Get the operating conditions and identify the ports feeding the MOs
op = operspec(modelname);
ports = get_param(blockname, 'PortHandles');
portcon = get_param(blockname, 'PortConnectivity');
mosrc = getfullname(portcon(1).SrcBlock);
moport = get_param(mosrc,'PortHandles');

%% Remove any existing constraints already attached to the MO or MV
op.Outputs(strcmp(blockname,get(op.Outputs,{'Block'}))) = [];
op.Outputs(strcmp(mosrc,get(op.Outputs,{'Block'}))) = [];

%% Add output constraints for MO and MV
op = addoutputspec(op,blockname,1);
op = addoutputspec(op,mosrc,portcon(1).SrcPort+1); %SrcPort C->M conversion

%% Assign constaint values to newly created constraint objects
for k=1:length(op.Outputs)
    if strcmp(op.Outputs(k).Block,blockname)
        set(op.Outputs(k),'Known',true*ones(size(u)),'y',u,...
            'Description','MV');
    end
    if  strcmp(op.Outputs(k).Block,mosrc)
        set(op.Outputs(k),'Known',true*ones(size(y)),'y',y,...
            'Description','MO');
    end
end
