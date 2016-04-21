% Mask Initialization for the counter section of Quanser Q8 Data Acquisition System
% Copyright 1996-2003 The MathWorks, Inc.

function [maskDisplay, maskDescription, mode, showArm, reset, initLoCount, initHiCount, pciBus, pciSlot] = ...
    mcntquanserq8(phase, channel, mode, showArm, reset, initLoCount, initHiCount, slot);

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
      return
    end

    vendorName  = 'Quanser';
    description = 'Counter';  
    deviceName  = 'Q8';
    maxChan     = 2;
           
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
    if ~isa(channel, 'double') || size(channel, 1) > 1 || size(channel, 2) > maxChan || ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector must be a row vector of not more than ' num2str(maxChan) ' integers in the range 1-' num2str(maxChan)]);
    end
     
    %%% check and scalar-expand the following parameters as necessary

    mode = scalarExpand( mode, 'Mode', 0, 1, [], channel );

    showArm = scalarExpand( showArm, 'Show arm', 0, 1, [], channel );

    reset = scalarExpand( reset, 'Reset', 0, 1, [], channel );

    initLoCount = scalarExpand( initLoCount, 'Initial low count', 0, hex2dec('ffffffff'), [], channel );
    
    initHiCount = scalarExpand( initHiCount, 'Initial high count', 0, hex2dec('ffffffff'), [], channel );

        
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
    j = 1;
    for i = 1:length(channel)
        if mode(i) == 0
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');',  maskDisplay, j, channel(i)); j = j+1;
        else
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i lo'');', maskDisplay, j, channel(i)); j = j+1;
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i hi'');', maskDisplay, j, channel(i)); j = j+1;
        end
        if showArm(i) == 1
            maskDisplay = sprintf('%s port_label(''input'', %i, ''%i arm'');', maskDisplay, j, channel(i)); j = j+1;
        end       
    end         
   
    % compute maskDescription
    maskDescription = [deviceName 10 vendorName 10 description];

    
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

