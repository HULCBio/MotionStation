% Mask Initialization for the A/D section of Quanser Q8 Data Acquisition System
% Copyright 1996-2003 The MathWorks, Inc.

function [index03, index47, pciBus, pciSlot, maskDisplay, maskDescription] = ...
    madquanserq8( phase, channel, sampleTime, slot )

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName  = 'Quanser';
    deviceName  = 'Q8';
    description = 'Analog Input';
    maxChan     = 8;

    if phase ~= 2  % InitFcn 
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
    
    %%% compute the index vectors: if chan is the vector of 0-based input channels
    %%% (not necessarily sorted), then we compute auxiliary vectors (sets) index03
    %%% and index47 with the following properties:
    %%%  . chan is the union of the sets chan(index03) and chan(index47)
    %%%  . chan(index03) is contained in [0:3] and is sorted
    %%%  . chan(index47) is contained in [4:7] and is sorted
        
    [sorted, index] = sort(channel - 1);
    index03 = index(ismember(sorted, [0:3])) - 1;  
    index47 = index(ismember(sorted, [4:7])) - 1; 
     
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
