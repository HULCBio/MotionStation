function [wiring, pciBus, pciSlot, maskDisplay, maskDescription] = ...
mldnaii76xx1(phase, deviceName, channel, wiring, frequency, voltage, sampleTime, slot);

% InitFcn and mask Initialization for the L/D section of NAII Apex 76xx1 series LVDT/RVDT 
% Copyright 2003 The MathWorks, Inc.

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName = 'NAII Apex';
    direction  = 'L/D';
    
    switch deviceName
        case '76CL1 (PCI)'
            maskType = 'naii_76cl1_ld';
            maxChan  = 8;
        case '76LD1 (PCI)'
            maskType = 'naii_76ld1_ld';
            maxChan  = 12;
        otherwise error(['Unsupported deviceName: ' deviceName]);
    end

            
            
    if phase == 1 % InitFcn
        slot = get_param( gcb, 'slot' );
        
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' direction ' block allowed per physical board (i.e. at the same slot)']);
        end
        
        return
    end

    if phase == 2 % mask initialization
        
        %%% check Channel vector parameter
        if ~isa(channel, 'double') || size(channel, 1) > 1 || ~all(ismember(channel, [1:maxChan]))
            error(['Channel vector must be a row vector of integers in the range 1-' num2str(maxChan)]);
        end
         
        %%% check Wiring vector parameter
        if ~isa(wiring, 'double') || ~all(ismember(wiring, [2 3]))
            error('Wiring vector elements must be either 2 (for 2-wire) or 3 (for 3-wire or 4-wire)');
        end
        if size(wiring) == [1 1]
            wiring = wiring * ones(size(channel));
        elseif ~all(size(wiring) == size(channel))
            error('Wiring vector must be a scalar or have the same number of elements as the Channel vector');
        end
             
        %%% check Frequency parameter
        if ~isa(frequency, 'double') || any(size(frequency) ~= [1 1]) || (frequency < 360) || (frequency > 10000)
            error('Excitation frequency must be a number in the range 360-10000');
        end
         
        %%% check Voltage parameter
        if ~isa(voltage, 'double') || any(size(voltage) ~= [1 1]) || ~( ismember(voltage, [0 115]) || (2 <= voltage && voltage <= 28) )
            error('Excitation voltage must be either 0, 115, or a number in the range 2.0 - 28.0');
        end
         
        %%% check Sample time parameter
        if ~isa(sampleTime, 'double') || any(size(sampleTime) ~= 1) || sampleTime <= 0 
            error('Sample time parameter must be a scalar > 0');
        end
        
        %%% check PCI slot parameter
        if ~isa(slot, 'double')
            error('PCI slot parameter must be of class double');
        elseif size(slot) == [1 1]
            pciBus = 0;
            pciSlot = slot;
        elseif size(slot) == [1 2]
            pciBus = slot(1);
            pciSlot = slot(2);
        else
            error('PCI Slot parameter must be a scalar (bus 0 assumed) or a vector of the form [bus slot]');
        end
       
        %%% compute maskDisplay and maskDescription
        maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, direction);
        for i = 1 : length(channel)
            maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
        end  
        
        maskDescription = [deviceName 10 vendorName 10 direction];
        
        return
    end
    
