function [carrier, maskDisplay, maskDescription] = mdiosbsdig24(carrierId, carrierSlot, channel, sampleTime, direction, reset, initValue)

% msdiosbsdig24 - Mask Initialization for Digital I/O for SBS IP-Digital 24
% The final two parameters (reset and initValue) are used only when direction = Output.  

% Copyright 1996-2003 The MathWorks, Inc.

    channelsPerPort = 24;

    %%% check Carrier ID parameter

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end


    %%% check Channel vector parameter

    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    end

    if size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    end

    channel = round(channel);

    if ~all(ismember(channel, [1:channelsPerPort]))
        error(['Channel vector elements must be in the range 1..' num2str(channelsPerPort)]);
    end
     

    %%% check sampleTime parameter

    if ~isa(sampleTime, 'double')
        error('Sample Time parameter must be of class double');
    end

    if size(sampleTime) ~= [1 1]
        error('Sample Time parameter must be a scalar');
    end


    %%% check if our UserData has been loaded yet by the carrier block's InitFCN 
    try
        carrier = get_param(gcb, 'UserData');  
        maxSlot = carrier.maxSlot;
    catch % InitFcn hasn't run yet 
		carrier.type = 0;
		carrier.isaBase = 0;
		carrier.pciBus = 0;
		carrier.pciSlot = 0;
        carrier.maxSlot = 99;
    end

    %%% check carrierSlot parameter
    
    if carrierSlot > carrier.maxSlot
        error(['Carrier has no slot ' char('@' + carrierSlot)]);
    end
 

    %%% compute maskDisplay and maskDescription
    %%% check extra parameters if direction = Output

    switch direction
        case 'Input'
            portparam = 'output';
            blocktype = 'Digital Input';
        case 'Output'
            portparam = 'input';
            blocktype = 'Digital Output';
            
            %%% check reset vector parameter
            if ~isa(reset, 'double')
                error('Reset vector parameter must be of class double');
            end

            if size(reset) == [1 1]
                reset = reset * ones(size(channel));
            elseif ~all(size(reset) == size(channel))
                error('Reset parameter must be a scalar or the same shape as the Channel parameter');
            end

            reset = round(reset);
            
            if ~all(ismember(reset, [0 1]))
                error('Reset vector elements must be 0 or 1');
            end
     
            %%% check initValue vector parameter
            if ~isa(initValue, 'double')
                error('Initial value vector parameter must be of class double');
            end

            if size(initValue) == [1 1]
                initValue = initValue * ones(size(channel));
            elseif ~all(size(initValue) == size(channel))
                error('Initial value parameter must be a scalar or the same shape as the Channel parameter');
            end

            initValue = round(initValue);
            
            if ~all(ismember(initValue, [0 1]))
                error('Initial value vector elements must be 0 or 1');
            end
                
        otherwise
            error(['bad direction parameter: ' direction]);
    end

    maskDisplay = sprintf('disp(''IP-Digital 24\\nSBS\\nDigital %s'');', direction);

    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskDisplay, portparam, i, channel(i));
    end         

    maskDescription = ['IP-Digital 24' 10 'SBS' 10 'Digital ' direction];
