function xpcmt(targets, target)

% XPCMT - xPC Target Multiple Target Function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.2.2 $ $Date: 2004/04/08 21:05:07 $

xpcinit;
load(xpcenvdata);

if ~strcmp(actpropval{11},'TcpIp')
    error('xPC Target Setup: Property HostTargetComm is not set to TcpIp');
end

% set default target
if nargin==0
    settarget(actpropval);
    return
end

% set specific target

checkTargets(targets);
found=0;
for k=1:length(targets);
    if strcmp(targets(k).Name,target)
        if found
            error('Ambiguous Target Name defined');
        end
        found=k;
    end
end
if ~found
  error('Could not find target with specified name');
end
actpropval{14}=targets(found).TcpIpTargetAddress;
actpropval{15}=targets(found).TcpIpTargetPort;
actpropval{16}=targets(found).TcpIpSubNetMask;
actpropval{17}=targets(found).TcpIpGateway;
settarget(actpropval);

function checkTargets(targets)

if ~isa(targets,'struct')
    error('first argument must be a Struct defining the different targets');
end
if size(targets,1)~=1
  error('Targets struct must be a row vector struct');
end
for k=1:length(targets)
  tmp=targets(k);
  if ~isfield(tmp,'Name')
    error('Targets struct must have field: Name');
  end
  if ~isfield(tmp,'TcpIpTargetAddress')
    error('Targets struct must have field: TcpIpTargetAddress');
  end
  if ~isfield(tmp,'TcpIpTargetPort')
    error('Targets struct must have field: TcpIpTargetPort');
  end
  if ~isfield(tmp,'TcpIpSubNetMask')
    error('Targets struct must have field: TcpIpSubNetMask');
  end
  if ~isfield(tmp,'TcpIpGateway')
    error('Targets struct must have field: TcpIpGateway');
  end
  if ~isa(tmp.Name,'char')
    error('Targets struct: Name field value must be of class char');
  end
  if ~isa(tmp.TcpIpTargetAddress,'char')
    error('Targets struct: TcpIpTargetAddress field value must be of class char');
  end
  if ~isa(tmp.TcpIpTargetPort,'char')
    error('Targets struct: TcpIpTargetPort field value must be of class char');
  end
  if ~isa(tmp.TcpIpSubNetMask,'char')
    error('Targets struct: TcpIpSubNetMask field value must be of class char');
  end
  if ~isa(tmp.TcpIpGateway,'char')
    error('Targets struct: TcpIpGateway field value must be of class char');
  end
end

function settarget(propval)

xpcgate('closecom');
clear mex
if ~strcmp(xpctargetping,'success')
    error('setting new target failed');
end
