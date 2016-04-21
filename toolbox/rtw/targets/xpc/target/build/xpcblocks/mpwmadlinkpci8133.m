function [device, pciBus, pciSlot, maskDisplay, maskDescription, reset, initValue] = mpwmadlinkpci8133(phase, period, deadTime, channel, sampletime, slot, reset, initValue)

% Copyright 2003 The MathWorks, Inc.
    
    if phase ~= 2  % assume InitFcn unless phase 2
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error('Model contains two blocks of this type at the same PCI slot');
        end
        return
    end

    vendorName = 'Adlink';
    device = 1;
    deviceName = 'PCI-8133';
    description = '3-phase PWM';
    portDirection = 'input';
    
    %%% check Period parameter
    if ~isa(period, 'double')
        error('Factor n parameter must be of class double');
    elseif size(period, 1) > 1 | size(period, 2) > 1
        error('Factor n parameter must be a scalar');
    elseif period<0
        error('Factor n value must satisfy 0 < n < 65536');
    elseif period>65536
        error('Factor n value must satisfy 0 < n < 65536');
    end
    
    %%% check deadTime parameter
    if ~isa(deadTime, 'double')
        error('Factor m parameter must be of class double');
    elseif size(deadTime, 1) > 1 | size(deadTime, 2) > 1
        error('Factor m parameter must be a scalar');
    elseif deadTime<0
        error('Factor m value must satisfy 0 < m < 256');
    elseif deadTime>65536
        error('Factor m value must satisfy 0 < m < 256');
    end
    
    %%% check Channel parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:3]))
        error('Channel vector entries must be in the range 1..3');
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
    
    %%% check Reset vector parameter
	if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
    elseif all(size(reset) == [1 1])
        reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
        error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
    end
    if ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    end
	
	%%% check Initial value vector parameter
	if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
    elseif all(size(initValue) == [1 1])
        initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
        error('Initial value must be a scalar or have the same number of elements as the Channel vector');
    end
 
    %%% check PCI slot parameter
    if ~isa(slot, 'double')
        error('PCI Slot parameter must be of class double');
    elseif size(slot) == [1 1]
        pciBus = 0;
        pciSlot = slot;
    elseif size(slot) == [1 2]
        pciBus = slot(1);
        pciSlot = slot(2);
    else
        error('PCI Slot parameter must be a scalar (bus 0 assumed) or a vector of the form [bus slot]');
    end

    
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    channelstr={'U','V','W'};
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''%s'', %i, ''%s'');', maskDisplay, portDirection, i, channelstr{i});
    end         
    
    maskDescription = [deviceName 10 vendorName 10 description];



