function [reset, initValue, wiring, ratio, pciBus, pciSlot, maskDisplay, maskDescription] = ...
mdlnaii76cl1(phase, channel, reset, initValue, wiring, ratio, showStatus, frequency, voltage, sampleTime, slot);

% InitFcn and mask Initialization for the D/L section of NAII Apex 76CL1 series LVDT/RVDT 
% Copyright 2003 The MathWorks, Inc.

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
        return
    end

    vendorName = 'NAII Apex';
    deviceName = '76CL1 (PCI)';
    direction  = 'D/L';
    dlMaskType = 'naii_76cl1_dl';
    ldMaskType = 'naii_76cl1_ld';
    maxChan    = 6;
    
    if phase == 1 % InitFcn
        % Only one D/L allowed per slot. Also any L/D at the same slot as ours  
        % must use the same reference frequency and voltage as our block does. 
        
        slot = get_param( gcb, 'slot' );
        
		dlBlock = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', dlMaskType, 'slot', slot);
        
		if length(dlBlock) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' direction ' block allowed per physical board (i.e. at the same slot)']);
		end
        
        ldBlock = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', ldMaskType, 'slot', slot);
        
        if length(ldBlock) == 0
            return;
            
        elseif evalin('caller', get_param(ldBlock{1}, 'frequency')) ~= evalin('caller', get_param(dlBlock{1}, 'frequency'))
            error('Excitation frequency in this D/L block differs from the frequency specified in a 76CL1 L/D block in the model');
            
        elseif evalin('caller', get_param(ldBlock{1}, 'voltage')) ~= evalin('caller', get_param(dlBlock{1}, 'voltage'))
            error('Excitation voltage in this D/L block differs from the voltage specified in a 76CL1 L/D block in the model');
        end
        
		return
    end

    if phase == 2 % mask initialization
        
        %%% check Channel vector parameter
        if ~isa(channel, 'double') || size(channel, 1) > 1 || ~all(ismember(channel, [1:maxChan]))
            error(['Channel vector must be a row vector of integers in the range 1-' num2str(maxChan)]);
        end
         
        %%% check Reset vector parameter
		if ~isa(reset, 'double') || ~all(ismember(reset, [0:1]))
          error('Reset vector entries must be 0 or 1');
		end
		if all(size(reset) == [1 1])
          reset = reset * ones(size(channel));
		elseif ~all(size(reset) == size(channel))
          error('Reset parameter must be a scalar or have the same number of elements as the Channel vector');
		end
    
        %%% check Initial value vector parameter
		if ~isa(initValue, 'double') || any( abs(initValue) > 1 )
          error('Initial value vector entries must be of class double and lie between -1 and 1');
		end
		if all(size(initValue) == [1 1])
          initValue = initValue * ones(size(channel));
		elseif ~all(size(initValue) == size(channel))
          error('Initial value must be a scalar or have the same number of elements as the Channel vector');
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
             
        %%% check Two-speed ratio parameter
        if ~isa(ratio, 'double') || any(ratio < 0) || any(ratio > 2)
            error('Two-speed ratio vector elements must be real numbers between 0 and 2');
        elseif size(ratio) == [1 1]
            ratio = ratio * ones(size(channel));
        elseif ~all(size(ratio) == size(channel))
            error('Two-speed ratio parameter must be a scalar or a vector the same length as the Channel vector');
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
            if wiring(i) == 2
                label = 'AB';
            else 
                label = '';
            end;
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i%s'');', maskDisplay, i, channel(i), label);
        end  
        if showStatus
            maskDisplay = sprintf('%s port_label(''output'', 1, ''S'');', maskDisplay);
        end
        
        maskDescription = [deviceName 10 vendorName 10 direction];
        
        return
    end
    
