% Mask Initialization for the D/A section of Quanser Q8 Data Acquisition System
% Copyright 1996-2003 The MathWorks, Inc.

function [maskDisplay, maskDescription, range, reset, initValue, pciBus, pciSlot] = ...
    mdaquanserq8(phase, channel, range, reset, initValue, slot)

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName  = 'Quanser';
    description = 'Analog Output';  
    deviceName  = 'Q8';
    maxChan     = 8;
           
    if phase ~= 2  % assume InitFcn unless phase 2
        maskType = get_param( gcb, 'MaskType' );
        slot = get_param( gcb, 'slot' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block allowed per physical board']);
        end
        return
    end  
 
    %%% check Channel vector parameter
    if ~isa(channel, 'double') || size(channel, 1) > 1 || ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector must be a row vector of integers in the range 1-' num2str(maxChan)]);
    end
     
    %%% check Range vector parameter
    if ~isa(range, 'double') || ~all(ismember(range, [10, -5, -10]))
      error('Range vector entries must be one of the values 10, -5, or -10');
    end
    if all(size(range) == [1 1])
      range = range * ones(size(channel));
    elseif ~all(size(range) == size(channel))
      error('Range parameter must be a scalar or have the same number of elements as the Channel vector');
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
    if all(size(initValue) == [1 1])
      initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
      error('Initial value must be a scalar or have the same number of elements as the Channel vector');
    end
    maxValue = abs(range);
    minValue = range .* (range < 0);
    if ~isa(initValue, 'double') || any(initValue < minValue) || any(initValue > maxValue)
      error('Initial value vector entries must be of class double and lie in the range specified by the corresponding Range parameter entries');
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
    
    % compute maskDisplay
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
   
    % compute maskDescription
    maskDescription = [deviceName 10 vendorName 10 description];

