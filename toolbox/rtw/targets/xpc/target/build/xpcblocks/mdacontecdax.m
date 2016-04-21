function [maskDisplay, maskDescription, range, reset, initValue, pciBus, pciSlot] = mdacontecdax( phase, channel, range, reset, initValue, slot, device )

    if phase ~= 2  % assume InitFcn unless phase 2
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error('Model contains two blocks of this type at the same PCI slot');
        end
        return
    end
    
    vendorName  = 'Contec';
    description = 'Analog Output';
   
    switch device
        case 1  
            maxChan = 4;
            deviceName = 'DA12-4(PCI)';
        case 2  
            maxChan = 16;
            deviceName = 'DA12-16(PCI)';
        otherwise
            error('mdacontecdax: bad device param');
    end
            
            
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector entries must be in the range 1-' num2str(maxChan)]);
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
     
    %%% check range vector parameter
    if ~isa(range, 'double')
        error('Range vector parameter must be of class double');
    elseif ~all(ismember(range, [-10 -5 10]))
        error('Range vector elements must be chosen from the values -5 -10 10');
    elseif (size(range) == [1 1])
        range = range * ones(size(channel));
    elseif size(range) ~= size(channel)
        error('Range vector must be a scalar or have the same number of elements as the Channel vector');
    end

    %%% check reset vector parameter
    if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
    elseif size(reset) == [1 1]
        reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
        error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
    end
    if ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    end

    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
    elseif size(initValue) == [1 1]
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
   
    
    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/06/06 15:56:29 $
