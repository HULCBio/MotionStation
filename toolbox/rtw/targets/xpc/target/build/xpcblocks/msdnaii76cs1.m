function [ratio, hiRes, synchro, maxRps, pciBus, pciSlot, maskDisplay, maskDescription] = ...
    msdnaii76cs1(phase, channel, ratio, hiRes, synchro, encoder, maxRps, dynamicMaxRps, frequency, voltage, sampleTime, slot);

% Mask Initialization for the S/D section of NAII Apex 76CS1 series Synchro/Resolver boards
% Copyright 1996-2003 The MathWorks, Inc.

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName  = 'NAII Apex';
    deviceName  = '76CS1 (PCI)';
    description = 'S/D';
    maskType    = 'naii_76cs1_sd';
    maxChan     = 8;
    maxMaxRps   = 152.5878;
    
    if phase == 1 % InitFcn
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block allowed per physical board (i.e. at the same slot)']);
        end
        return
    end

    if phase == 2 % mask initilaization
        
        %%% check Channel vector parameter
        if ~isa(channel, 'double') || size(channel, 1) > 1 || ~all(ismember(channel, [1:maxChan]))
            error(['Channel vector must be a row vector of integers in the range 1-' num2str(maxChan)]);
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
        
        if ~isempty(intersect(channel+1, channel(ratio > 1)))
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
        
        %%% check Synchro vector parameter
        if ~isa(synchro, 'double') || ~all(ismember(synchro, [0 1]))
            error('Synchro vector parameter elements must be 0 or 1');
        elseif size(synchro) == [1 1]
            synchro = synchro * ones(size(channel));
        elseif ~all(size(synchro) == size(channel))
            error('Synchro vector must be a scalar or a vector the same length as the Channel vector');
        end
        
        %%% check Encoder vector parameter
        if ~isa(encoder, 'double') || ~all(ismember(encoder, [4 6 8 12:16]))
            error('Encoder vector parameter elements must belong either to the set [4 6 8], indicating the number of poles for a commutator output, or to the set [12 13 14 15 16], indicating the number of bits of an encoder output');
        elseif size(encoder) == [1 1]
            encoder = encoder * ones(size(channel));
        elseif ~all(size(encoder) == size(channel))
            error('Encoder vector must be a scalar or a vector the same length as the Channel vector');
        end
        
        %%% check Max RPS vector parameter
        if ~isa(maxRps, 'double') || any(maxRps < 0) || any(maxRps > maxMaxRps)
            error(['Max RPS vector elements must be between 0 and ' num2str(maxMaxRps)]);
        elseif size(maxRps) == [1 1]
            maxRps = maxRps * ones(size(channel));
        elseif ~all(size(maxRps) == size(channel))
            error('Max RPS vector must be a scalar or a vector the same length as the Channel vector');
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
            maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
        end  
        
        if dynamicMaxRps
            for i = 1 : length(channel)
                maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
            end  
        end
        
        % compute maskDescription
        maskDescription = [deviceName 10 vendorName 10 description];
        
        return
    end
    
