function [maskDisplay, maskDescription] = mtargetboxwatchdog( phase, interval, portReset, sampleTime )

    deviceName   = 'TargetBox 10x120x';
    vendorName   = 'The MathWorks';
    description  = 'Watchdog';
    maskType     = 'targetboxwatchdog';

    if phase ~= 2  % assume InitFcn unless phase 2
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType);
        if length(blocks) > 1
            error('Only one TargetBox watchdog block per model.');
        end
        return
    end
     
     
    %%% check timeout interval parameter
    if ~isa(interval, 'double')
      error('Watchdog timeout interval parameter must be of class double');
    elseif size(interval, 1) > 1 | size(interval, 2) > 1
      error('Watchdog timeout interval parameter must be a scalar');
    elseif interval < 1 | interval > 255
      error('Watchdog timeout interval parameter must be in the range 1..255');
    end
    
     
    %%% check sampleTime parameter
    if ~isa(sampleTime, 'double')
      error('Sample Time parameter must be of class double');
    elseif size(sampleTime, 1) > 1 | size(sampleTime, 2) > 1
      error('Sample Time parameter must be a scalar');
    end
    
    
    % compute maskDisplay and maskDescription
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    if portReset
        maskDisplay = [maskDisplay 'port_label(''input'', 1, ''R'');'];
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];
    

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:03:12 $
