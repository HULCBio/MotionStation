function [maskDisplay, maskDescription, reset, initValue] = mtargetboxleds( phase, leds, reset, initValue, sampleTime )

    deviceName   = 'TargetBox 10x120x';
    vendorName   = 'The MathWorks';
    description  = 'LED';
    maskType     = 'targetboxleds';

    if phase ~= 2  % assume InitFcn unless phase 2
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType);
        if length(blocks) > 1
            error('Only one TargetBox LEDs block per physical board allowed in a model.');
        end
        return
    end
    
    
    %%% check LEDs vector parameter
    if ~isa(leds, 'double')
        error('LEDs vector parameter must be of class double');
    elseif size(leds, 1) > 1
        error('LEDs vector parameter must be a row vector');
    elseif ~all(ismember(leds, [1:2]))
        error('LEDs vector entries must be 1 or 2');
    elseif length(leds) ~= length(unique(leds))
        error('LEDs vector entries must be distinct');
    end
     
    %%% check reset vector parameter
    if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
    elseif ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    elseif size(reset) == [1 1]
        reset = reset * ones(size(leds));
    elseif ~all(size(reset) == size(leds))
        error('Reset vector must be a scalar or have the same number of elements as the LEDs vector');
    end

    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
    elseif ~all(ismember(initValue, [0 1]))
        error('Initial value vector elements must be 0 or 1');
    elseif size(initValue) == [1 1]
        initValue = initValue * ones(size(leds));
    elseif ~all(size(initValue) == size(leds))
        error('Initial value must be a scalar or have the same number of elements as the LEDs vector');
    end
  
    %%% check sampleTime parameter
    if ~isa(sampleTime, 'double')
      error('Sample Time parameter must be of class double');
    elseif size(sampleTime, 1) > 1 | size(sampleTime, 2) > 1
      error('Sample Time parameter must be a scalar');
    end
    
    % compute maskDisplay and maskDescription
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(leds)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, leds(i));
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];
    

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/08 21:03:11 $
