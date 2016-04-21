% Mask Initialization for the encoder input section of Quanser Q8 Data Acquisition System
% Copyright 1996-2004 The MathWorks, Inc.

function [initialCount, prescale, quadrature, mode, synchronousIndex, indexPolarity, preserveCounts, pciBus, pciSlot, maskDisplay, maskDescription] = ...
    mencquanserq8( phase, channel, initialCount, prescale, quadrature, mode, synchronousIndex, indexPolarity, preserveCounts, sampleTime, slot )

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return;
    end

    vendorName  = 'Quanser';
    deviceName  = 'Q8';
    description = 'Incremental Encoder';
    maxCount    = hex2dec('ffffff');
    maxChan     = 8;

    if phase == 1  % InitFcn 
        slot = get_param( gcb, 'slot' );
        maskType = get_param( gcb, 'maskType' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'slot', slot);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block allowed per physical board']);
        end
        return;
    end

    %%% check Channel vector parameter

    if ~isa(channel, 'double') || size(channel, 1) > 1 || ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector must be a row vector of integers in the range 1-' num2str(maxChan)]);
    end
   
    %%% check and scalar-expand the following parameters as necessary

    initialCount = scalarExpand( initialCount, 'Initial count', 0, maxCount, [], channel );

    prescale = scalarExpand( prescale, 'Prescale', 0, 256, [], channel );

    quadrature = scalarExpand( quadrature, 'Quadrature', 1, 0, [0 1 2 4], channel );

    mode = scalarExpand( mode, 'Mode', 0, 3, [], channel );

    synchronousIndex = scalarExpand( synchronousIndex, 'Synchronous index', 0, 1, [], channel );

    indexPolarity = scalarExpand( indexPolarity, 'Index polarity', 0, 1, [], channel );

    preserveCounts = scalarExpand( preserveCounts, 'Preserve counts', 0, 1, [], channel );

    if any((synchronousIndex  == 1) & (quadrature == 0))
        error('Synchronous index not allowed for normal mode');
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
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         

    % compute maskDescription

    maskDescription = [deviceName 10 vendorName 10 description];
    
    return;
 
    
function [param] = scalarExpand( param, paramstr, lo, hi, range, channel )
    if ~isa(param, 'double') 
        error([paramstr ' parameter must be of type double']);
    end
    
    if lo <= hi 
        if any(param < lo) || any(param > hi)
            error([paramstr ' parameter entries must be between ' num2str(lo) ' and ' num2str(hi)]);
        end

    elseif ~all(ismember(param, range))
        error([paramstr ' parameter entries must be in [' num2str(range) ']']);
    end
    
    if all(size(param) == [1 1])
        param = param * ones(size(channel));
    elseif ~all(size(param) == size(channel))
        error([paramstr ' must be a scalar or a vector with the same number of elements as the Channel vector']);
    end
    
    return;

