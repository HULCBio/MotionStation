function [maskDisplay, maskDescription, pciBus, pciSlot] = mencnipci660x( phase, device, channel, initCount, slot )

% Copyright 2003-2004 The MathWorks, Inc.
    
    if phase == 1  % InitFcn
        % Ensure that no 660x blocks associated with our bus slot use any common channels.
        % This InitFcn is also called by 660x PWM and period/pulsewidth measurement blocks.
        
        chans = []; 
        masktype = get_param( gcb, 'MaskType' );
        ctrtype = ['ctr', masktype(4:end)];
        pwmtype = ['pwm', masktype(4:end)];
        enctype = ['enc', masktype(4:end)];
        maskTypes = [ctrtype, '|', pwmtype, '|', enctype];
        myId = id( evalin('caller', get_param(gcb, 'slot')) );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskType', maskTypes );
        for i = 1:length(blocks)
            slot = evalin('caller', get_param(blocks{i}, 'slot'));
            if id(slot) == myId
                chan = evalin('caller', get_param(blocks{i}, 'channel'));
                if ismember(chan, chans)
                    error(['Model contains two or more 660x-type blocks at slot ' num2str(slot) ' which use channel ' num2str(chan)]);
                else
                    chans = union(chans, chan);
                end
            end
        end
        return
    end
    
    if phase == 2 % mask init
        vendorName  = 'National Instr.';
        description = 'Inc. Encoder';
        name = {'PCI-6601', 'PCI-6602', 'PXI-6602'};
      
        if ~ismember(device, [0:2])
            error(['Bad device parameter: ' num2str(device)]);
        else
            device = device + 1; % Cleve-ify the device index
        end
                
        if ~isa(initCount, 'double') | ~all(size(initCount) == 1)
            error('Initial count parameter must be a scalar of class double');
        end
	
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
       
        maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', name{device}, vendorName, description);
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, 1, channel);
	
        maskDescription = [name{device} 10 vendorName 10 description];
        return
    end
    
    function result = id(slot)
        if all(size(slot) == 1)
            slot = [0 slot];
        end
        result = 256 * slot(1) + slot(2);

