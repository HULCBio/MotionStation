function [reset, initValue, ratio, hiRes, pciBus, pciSlot, maskDisplay, maskDescription] = ...
    mdsnaii76cs1(phase, channel, reset, initValue, ratio, hiRes, showStatus, frequency, voltage, sampleTime, slot);

% Mask Initialization for the D/S section of NAII Apex 76CS1 series Synchro/Resolver boards
% Copyright 1996-2003 The MathWorks, Inc.

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName  = 'NAII Apex';
    deviceName  = '76CS1 (PCI)';
    description = 'D/S';
    dsMaskType  = 'naii_76cl1_ds';
    sdMaskType  = 'naii_76cl1_sd';
    maxChan     = 6;
    
    if phase == 1 % InitFcn
        % Only one D/S allowed per slot. Also any S/D at the same slot as ours  
        % must use the same reference frequency and voltage as our block does. 
        
        slot = get_param( gcb, 'slot' );
        
		dsBlock = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', dsMaskType, 'slot', slot);
        
		if length(dsBlock) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' direction ' block allowed per physical board (i.e. at the same slot)']);
		end
        
        sdBlock = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', sdMaskType, 'slot', slot);
        
        if length(sdBlock) == 0
            return;
            
        elseif evalin('caller', get_param(sdBlock{1}, 'frequency')) ~= evalin('caller', get_param(dsBlock{1}, 'frequency'))
            error('Excitation frequency in this D/S block differs from the frequency specified in a 76CL1 S/D block in the model');
            
        elseif evalin('caller', get_param(sdBlock{1}, 'voltage')) ~= evalin('caller', get_param(dsBlock{1}, 'voltage'))
            error('Excitation voltage in this D/S block differs from the voltage specified in a 76CL1 S/D block in the model');
        end
        
		return
    end

    if phase == 2 % mask initilaization
        
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
        
        %%% check Two-speed ratio vector parameter
        if ~isa(ratio, 'double') || any(ratio ~= round(ratio)) || any(ratio < 1)
            error('Two-speed ratio vector elements must be integers greater than 0');
        end
        
        if size(ratio) == [1 1]
            ratio = ratio * ones(size(channel));
        elseif ~all(size(ratio) == size(channel))
            error('Two-speed ratio vector must be a scalar or have the same number of elements as the Channel vector');
        end
        
        if any((ratio > 1) & (mod(channel, 2) == 1))
            error('Cannot specify a two-speed ratio > 1 for an odd channel');
        end
        
        if any(intersect(channel+1, (ratio > 1) .*  channel))
            error('Cannot specify a two-speed ratio > 1 for channel n if channel n-1 is already being used');
        end
        
            
        %%% check High resolution vector parameter
        if ~isa(hiRes, 'double') || ~all(ismember(hiRes, [0 1]))
            error('High resolution vector elements must be 0 or 1');
        elseif size(hiRes) == [1 1]
            hiRes = hiRes * ones(size(channel));
        elseif ~all(size(hiRes) == size(channel))
            error('High resolution parameter must be a scalar or a vector the same length as the Channel vector');
        end
        
        if any(hiRes & (ratio == 1))
            error('You cannot select high resolution for a channel unless its two-speed ratio is > 1');
        end
        
        %%% check Excitation frequency parameter
        if ~isa(frequency, 'double') || any(size(frequency) ~= [1 1]) || (frequency < 47) || (frequency > 10000)
            error('Excitation frequency must be a number in the range 47-10000');
        end
         
        %%% check Excitation voltage parameter
        if ~isa(voltage, 'double') || any(size(voltage) ~= [1 1]) || ~( ismember(voltage, [0 115]) || (2 <= voltage && voltage <= 28) )
            error('Excitation voltage must be either 0, 115, or a number in the range 2.0 - 28.0');
        end
         
        %%% check sample time parameter
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
       
        % compute maskDisplay
        maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
        for i = 1 : length(channel)
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
        end  
        if showStatus
            maskDisplay = sprintf('%s port_label(''output'', 1, ''S'');', maskDisplay);
        end
        
        % compute maskDescription
        maskDescription = [deviceName 10 vendorName 10 description];
        
        return
    end
    
