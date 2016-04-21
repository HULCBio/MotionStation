function mpc_chkdimensions_sim

%MPC_CHK_DIMENSIONS Check correct dimensions of signals to MPC Simulink block

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/10 23:39:08 $   


mpcobjname=get_param(gcb,'mpcobj');

% (jgo) Run open loop when no mpcobj
if isempty(mpcobjname)
    return
end

% Retrieves object info from MPCstruct stored in block's Userdata 
mpcdata=get_param(gcb,'Userdata');
nym=mpcdata.nym;
nv=mpcdata.nv;
ny=mpcdata.ny;

ports=get_param(gcb,'PortConnectivity');
widths=get_param(gcb,'CompiledPortWidths');

errmsg=['Error in port widths or dimensions. The MPC object specifies that the number of %s is %d, '...
        'however %d are connected\n'];

err='';
if ~(ports(1).SrcBlock<0) & ... % if output signal is connected ...
        widths.Inport(1)~=nym,
   err=sprintf(errmsg,'measured outputs',nym,widths.Inport(1));
end

if ~(ports(2).SrcBlock<0) ... % if reference signal is connected ...
      & widths.Inport(2)~=ny,
   err=[err sprintf(errmsg,'reference signals',ny,widths.Inport(2))];
end

if ~(ports(3).SrcBlock<0) ... % if measured dist. signal is connected ...
      & widths.Inport(3)~=nv-1,
   err=[err sprintf(errmsg,'measured disturbances',nv-1,widths.Inport(3))];
end

if ~isempty(err),
   error('mpc:mpc_chkdimensions_sim:port',err);
end

