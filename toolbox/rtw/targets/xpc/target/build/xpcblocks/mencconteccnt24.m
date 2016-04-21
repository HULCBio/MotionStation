function [maskDisplay, maskDescription, pciBus, pciSlot] = mencconteccnt24( phase, channel, slot )

    deviceName  = 'CNT24-4D(PCI)';
    vendorName  = 'Contec';
    description = 'Inc. Encoder';
    maxChan     = 4;       
                
    if phase == 1  % InitFcn 
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error('Model contains two blocks of this type at the same PCI slot');
        end
        return;
    end
    
    if phase == 2 % mask init
    
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
            maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i) + 1);
        end         

        maskDescription = [deviceName 10 vendorName 10 description];
        return;
    end

    maskNames = get_param(gcb, 'MaskNames');
    currChannel = get_param( gcb, 'currChannel' );
    % names of the per-channel fields - 'enable' must come first
    names = {'enable', 'sel', 'mode', 'dir', 'zsel', 'zmode', 'filter', 'initCount'}; 
      
    if phase == 3 % callback for change in 'channel' parameter 
        
        % after the channel parameter changes, we manipulate the MaskVisibilities so that 
        % only the dialog parameters relevant to the currently selected channel are visible
        
        maskVisibilities = get_param(gcb, 'MaskVisibilities');
        
        for i = 1:maxChan
            chan = num2str(i);
            if chan == currChannel
                visibility = 'on';
            else
                visibility = 'off';
            end
            
            for j = 1:length(names)
                index = strmatch([names{j} chan], maskNames, 'exact');
                if ~isempty(index)
                    maskVisibilities{index} = visibility;
                end
            end
        end
        
        set_param(gcb, 'MaskVisibilities', maskVisibilities);
        return;
    end
    
    if phase == 4 % callback for change in 'enable' parameter
        
        maskEnables = get_param(gcb, 'MaskEnables');
         
        for i = 1:length(names)
            name = [names{i} currChannel];
            index = strmatch(name, maskNames, 'exact');
            if isempty(index)
                continue;
            end
            
            if i == 1 % 'enable'
                enable = get_param(gcb, name);
            else
                maskEnables{index} = enable;
            end
        end
            
        set_param(gcb, 'MaskEnables', maskEnables);
        return;
    end
  
            

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/08 21:02:59 $
