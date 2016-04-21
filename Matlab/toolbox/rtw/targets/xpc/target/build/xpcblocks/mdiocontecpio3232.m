function [pciBus, pciSlot, maskDisplay, maskDescription, reset, initValue] = mdiocontecpio3232(phase, ioFormat, channel, sampletime, slot, reset, initValue);
    
    vendorName = 'Contec';
    deviceName = 'PIO-32/32T';

    maskType = get_param(gcb, 'MaskType');
    
    switch maskType
        case 'dicontecpio3232T'
            portdirection = 'output';
            description = 'Digital Input';
            initResetPresent = 0;
        case 'docontecpio3232T'
            portdirection = 'input';
            description = 'Digital Output';
            initResetPresent = 1; % reset and initValue params are present only for digital output
        otherwise
            error('bad mask type');
    end

    if phase ~= 2  % assume InitFcn unless phase 2
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error(['Only one ' vendorName ' '  deviceName ' ' description ' block per physical board allowed in a model.']);
        end
        return
    end


    %%% check Channel parameter, and Init and Reset parameters if present
    switch ioFormat
        case 1 % serial
            max = 32;
            if ~isa(channel, 'double')
                error('Channel vector parameter must be of class double');
            elseif size(channel, 1) > 1
                error('Channel vector parameter must be a row vector');
            elseif ~all(ismember(channel, [1:max]))
                error(['Channel vector entries must be in the range 1-' num2str(max)]);
            elseif length(channel) ~= length(unique(channel))
                error('Channel vector entries must be distinct');
            end
            
            if initResetPresent
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
            end
            
        case 2 % parallel
            channel = [1];
            max = hex2dec('ffffffff');
            
            if initResetPresent
                %%% check reset vector parameter
                if ~isa(reset, 'double')
                    error('Reset parameter must be of class double');
                elseif any(size(reset) ~= [1 1])
                    error('Reset parameter must be a scalar when I/O format is parallel');
                elseif ~ismember(reset, [0 1])
                    error('Reset parameter must be 0 or 1');
                end
			
                %%% check initValue vector parameter
                if ~isa(initValue, 'double')
                    error('Initial value parameter must be of class double');
                elseif size(initValue) ~= [1 1]
                    error('Initial value parameter must be a scalar when I/O format is parallel');
                elseif initValue < 0 | initValue > max
                    error(['Initial value parameter must be in the range 0-' max]);
                end
            end
        otherwise
            error('bad I/O format');           
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
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskDisplay, portdirection, i, channel(i));
    end         
    
    maskDescription = [deviceName 10 vendorName 10 description];





%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/06/06 15:56:33 $
