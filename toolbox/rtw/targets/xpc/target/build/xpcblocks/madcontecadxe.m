function [maskDisplay, maskDescription, gain, pciBus, pciSlot] = madcontecadxe( phase, channel, gain, range, slot, device )

% Copyright 2002 The MathWorks, Inc.

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
    description = 'Analog Input';

    switch device
        case 0  
            deviceName = 'AD12-16(PCI)E';
        case 1  
            deviceName = 'AD12-16U(PCI)E';
        case 2  
            deviceName = 'AD16-16(PCI)E';
        otherwise
            error('bad device param');
    end
 
    if range <= 2      
        maxChan = 8;   % bipolar
    else
        maxChan = 16;  % unipolar
    end
    
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector entries must be in the range 1-' num2str(maxChan)]);
    end
     
    %%% check Gain vector parameter
    if ~isa(gain, 'double')
        error('Gain vector parameter must be of class double');
    elseif ~all(ismember(gain, [1, 2, 4, 8]))
        error('Gain vector elements must be chosen from the values 1, 2, 4, 8');
    elseif (size(gain) == [1 1])
        gain = gain * ones(size(channel));
    elseif size(gain) ~= size(channel)
        error('Gain vector must be a scalar or have the same number of elements as the Channel vector');
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
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];

