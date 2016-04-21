function argout = canblocks_ccp_validate(block, target, instance_str)
% Resource allocation function 

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1 $
%   $Date: 2002/08/15 15:03:08 $

% find a resource object
resource_obj = target.findResourceForClass('TargetsCommonConfig.CCP');
if isempty(resource_obj)
   error('Could not find configuration for TargetsCommonConfig.CCP');
end;

% get the instance resource from the resource object
resource = resource_obj.CCP_INSTANCE;

% Manual Allocation of the instance %
instance_str_alloc = resource.manual_allocate(block, instance_str);

if isempty(instance_str_alloc)
   host = resource.get_host(instance_str);
   if ischar(host)
      hilite_system(host, 'error');
      error(['Only one CAN Calibration Protocol (CCP) block is allowed in a target subsystem.   '...
             'More than one CCP block is in the target subsystem.   '...
             'To fix this error, please remove extra CCP blocks.']);
   else 
      % should never get here...
   end;
   open_system(block);
else
   % successful allocation
end;
      
argout = {instance_str};
