function [carrier, maskDisplay, maskDescription] = mdasbsipdac(carrierId, carrierSlot, channel, range, sampleTime)

% madsbsiphiadc - Mask Initialization for SBS IP-HiADC analog input

% Copyright 1996-2003 The MathWorks, Inc.


    %%% check Carrier ID parameter

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end
   
    %%% check Channel vector parameter and compute chanOffset

    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    end

    if size(channel, 1) > 1 | size(channel, 2) < 1
        error('Channel vector parameter must be a nonempty row vector');
    end

    channel = round(channel);

    if ~all(ismember(channel, [1:16]))
        error('Channel vector entries must be in the range 1-16');
    end
     
    %%% range parameter is a popup
   
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
		set_param(gcb, 'UserData', carrier); 
    end

    %%% check carrierSlot parameter
    
    if carrierSlot > carrier.maxSlot
        error(['Carrier has no slot ' char('@' + carrierSlot)]);
    end
 

    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''IP-HiADC\\nSBS\\nAnalog Input'');');

    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         

    maskDescription = ['IP-HiADC' 10 'SBS' 10 'Analog Input'];
