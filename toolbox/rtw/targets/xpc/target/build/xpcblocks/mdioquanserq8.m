% mdioquanserq8 - mask initialization for the digital I/O section of the
% Quanser Q8 Data Acquisition System

% Copyright 1996-2003 The MathWorks, Inc.

function [control, pciBus, pciSlot, maskDisplay, maskDescription, reset, initValue] = ...
    mdioquanserq8(phase, direction, channel, sampleTime, slot, reset, initValue)

    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
        return
    end

    maxChan = 32;

    switch direction
        case 'input'
            portDirection = 'output';
        case 'output'
            portDirection = 'input';
        otherwise 
            error('bad direction');
    end

    if phase == 1  % InitFcn 
        thisSlot = get_param(gcb, 'slot');
        
        diBlocks = find_system(gcs, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'quanser_q8_di', 'slot', thisSlot);
        doBlocks = find_system(gcs, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'quanser_q8_do', 'slot', thisSlot);
        
        % we test for direction here so as not to have the input block turn yellow when the problem 
        % is with the output block (or vice versa)
        switch direction
            case 'input'
                if length(diBlocks) > 1
                    error(['Only one Quanser Q8 digital input block allowed at slot ' thisSlot]);
                end
            case 'output'
                if length(doBlocks) > 1
                    error(['Only one Quanser Q8 digital output block allowed at slot ' thisSlot]);
                end
        end
       
        try
            diChans = evalin( 'caller', get_param(diBlocks{1}, 'channel') );
        catch
            diChans = [];
        end
        
        try
            doChans = evalin( 'caller', get_param(doBlocks{1}, 'channel') );
            UserData.control = sum( 2 .^ (doChans - 1) );
        catch
            doChans = [];
            UserData.control = 0;
        end
        
        shared = intersect(diChans, doChans);
        if length(shared) > 0
            error(['A Quanser Q8 digital input block and an output block are both trying to use channel ' num2str(shared(1))]);
        end
                   
        set_param(gcb, 'UserData', UserData);

        return
    end % if InitFcn
    
        
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
    if ~isa(initValue, 'double') || ~all(ismember(initValue, [0:1]))
        error('Initial value vector entries must be 0 or 1');
    end
    if all(size(initValue) == [1 1])
        initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
        error('Initial value must be a scalar or have the same number of elements as the Channel vector');
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
    maskDisplay = sprintf('disp(''Q8\\nQuanser\\nDigital %s'');', direction);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskDisplay, portDirection, i, channel(i));
    end         
   
    % compute maskDescription
    maskDescription = ['Q8' 10 'Quanser' 10 'Digital ' direction];
    
    % return control data from UserData
    try
        UserData = get_param(gcb, 'UserData');
        control = UserData.control;
    catch
        % InitFcn hasn't yet defined UserData, but we still need to be able to call 
        % mdlInitializeSizes, and so the S-function's 'control' parameter must be defined,
        % even though mdlStart won't be called this time
        control = 0; 
    end
    
    
