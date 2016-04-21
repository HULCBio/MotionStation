function [carrier, maskDisplay, maskDescription] = madsbsip16adc(carrierId, carrierSlot, channel, range, sampleTime)

% madsbsip16adc - Mask Initialization for SBS IP-16ADC analog input

% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/08 21:02:41 $


    %%% check Carrier ID parameter

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end
   
    %%% check Channel vector parameter

    if ~isa(channel, 'double')
        error('Channel parameter must be of class double');

    elseif size(channel, 1) > 1 | size(channel, 2) < 1
        error('Channel parameter must be a nonempty row vector');

	elseif length(channel) > 16
	    error('Channel parameter has more than 16 entries');
    end

    channel = round(channel);
    
    
    %%% check Range vector parameter

    if ~isa(range, 'double')
        error('Range parameter must be of class double');
    end

    if size(range) == [1 1]
        range = range * ones(size(channel));
    elseif ~all(size(range) == size(channel))
        error('Range parameter must be a scalar or the same shape as the Channel parameter');
    end

    range = round(range);
    
    if ~all(ismember(range, [5 10 -5 -10]))
        error('Range vector entries must be 5, 10, -5, or -10');
    end
    
    %%% check Channel/Range consistency 
    
    bipolar = zeros(size(channel));
    unipolar = zeros(size(channel));
    
    for i = 1:length(channel)
        if range(i) > 0
            if ~ismember(channel(i), [1:16])
                error('Unipolar channels must be in the range 1..16');
            else
                unipolar(i) = channel(i);
            end
        else 
            if ~ismember(channel(i), [1:8])
                error('Bipolar channels must be in the range 1..8');
            else
                bipolar(2*i) = channel(i);
                bipolar(2*i-1) = channel(i);
            end
        end
    end
 
    for i = 1:length(channel)
        if unipolar(i) & bipolar(i)
            error(['Bipolar channel ' num2str(bipolar(i)) ' and unipolar channel ' num2str(unipolar(i)) ' use the same I/O pins']);
        end
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

    maskDisplay = sprintf('disp(''IP-16ADC\\nSBS\\nAnalog Input'');');

    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         

    maskDescription = ['IP-16ADC' 10 'SBS' 10 'Analog Input'];
