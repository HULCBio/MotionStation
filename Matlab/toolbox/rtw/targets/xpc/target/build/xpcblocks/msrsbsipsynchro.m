function [carrier, channel, precision, maskDisplay, maskDescription] = msrsbsipsynchro(carrierId, carrierSlot, channel, precision, sampleTime)

% msrsbsipsynchro - Mask Initialization for SBS IP-Synchro synchro/resolver

% Copyright 1996-2003 The MathWorks, Inc.


    %%% check Carrier ID 

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end
   
    %%% check Channel vector 

    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    end

    channel = round(channel);

    if size(channel) ~= [1 1] & size(channel) ~= [1 2]
        error('Channel parameter must be a vector of length 1 or 2');
    end
    
    if length(channel) ~= length(sort(channel))
        error('Channel parameter must contain no repetitions');
    end
    
    if ~all(ismember(channel, [1 2]))
        error('Channel parameter entries must be 1 or 2');
    end

    
    %%% check Precision vector 

    if ~isa(precision, 'double')
        error('Precision vector parameter must be of class double');
    end

    precision = round(precision);
    
    if size(precision) == [1 1]
        precision = ones(size(channel)) * precision;
    end
    
    if any(size(precision) ~= size(channel))
        error('Precision vector parameter must be a scalar or a vector the same size as as the Channel vector parameter');
    end
    
    if ~all(ismember(precision, [10 12 14 16]))
        error('Precision vector entries must be chosen from 10, 12 14 16');
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
        maxSlot = 99;
    end

    %%% check carrierSlot parameter
    
    if carrierSlot > maxSlot
        error(['Carrier has no slot ' char('@' + carrierSlot)]);
    end
 

    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''IP-Synchro\\nSBS\\nSynchro/Resolver'');');

    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
    end    
       
    maskDescription = ['IP-Synchro' 10 'SBS' 10 'Synchro/Resolver'];
