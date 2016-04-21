function [carrier, range, maskDisplay, maskDescription] = mdasbsipdac(carrierId, carrierSlot, channel, range, reset, initValue, sampleTime)

% mdasbsipdac - Mask Initialization for SBS IP-DAC analog output

% Copyright 1996-2003 The MathWorks, Inc.


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

    if ~all(ismember(channel, [1:6]))
        error('Channel vector entries must be in the range 1-6');
    end
     
    if length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
     
    %%% check range vector parameter

    if ~isa(range, 'double')
        error('Range vector parameter must be of class double');
    end

    if (length(range) > 1) & (length(range) ~= length(channel)) 
        error('Range vector parameter must be either a scalar (scalar expansion applies) or a row vector with the same number of elements as the Channel vector');
    end

    % apply scalar expansion if necessary
    if size(range, 2) == 1
        range = range * ones(1, length(channel));
    end
    
    if ~all(ismember(range, [-10 -5 -2.5 5 10]))
        error('Range vector elements must be chosen from the values -10 -5 -2.5 5 10');
    end

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
 

    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''IP-DAC\\nSBS\\nAnalog Output'');');

    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         

    maskDescription = ['IP-DAC' 10 'SBS' 10 'Analog Output'];
