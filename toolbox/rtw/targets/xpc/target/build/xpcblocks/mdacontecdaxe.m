function [initValue, pciBus, pciSlot] = mdacontecdaxe( phase, initValue, slot, device )

    if phase ~= 2  % assume InitFcn unless phase 2
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error('Model contains two blocks of this type at the same PCI slot');
        end
        return
    end
    
    
    %%% check initValue parameter
    if ~isa(initValue, 'double')
        error('Initial value parameter must be of class double');
    elseif size(initValue) ~= [1 1]
        error('Initial value must be a scalar');
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
   
    

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:02:47 $
