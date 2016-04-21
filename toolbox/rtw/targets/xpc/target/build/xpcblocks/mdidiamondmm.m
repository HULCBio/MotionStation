function [baseDec, maskDisplay, maskDescription] = mdidiamondmm(phase, channel, sampleTime, base);

% Mask Initialization function for Diamond-MM digital input driver blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/11/25 20:10:27 $

    vendorName   = 'Diamond';
    deviceName   = 'MM';
    description  = 'Digital Input';
    maskType     = 'didiamondmm';
    maxChan      = 8;
    
    if phase ~= 2  % InitFcn
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block per physical board allowed in a model']);
        end
        return
    end

    %%% check Channel vector parameter
    if ~isa(channel, 'double') || size(channel,1) ~= 1 || length(channel) > maxChan
        error(['Channel vector must be a vector of class double and length between 1 and ' num2str(maxChan)]);
    elseif ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector entries must be in the range 1-' num2str(maxChan)]);
    end

    %%% check base parameter
    minBase = hex2dec('220');
    maxBase = hex2dec('3e0');
    incBase = hex2dec('020');
    baseMsg = 'Base address parameter must be one of 0x220, 0x240, ... 0x3e0';
    if ~isa(base, 'char') | length(base) ~= 5 | base(1:2) ~= '0x'
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
    end
    
    % compute maskDisplay
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1 : length(channel)
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, i);
    end 
    
    % compute maskDescription
    maskDescription = [deviceName 10 vendorName 10 description];
