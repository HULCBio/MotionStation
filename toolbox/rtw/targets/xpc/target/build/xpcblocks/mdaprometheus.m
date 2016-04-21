function [maskDisplay, maskDescription, reset, initValue, baseDec] = mdaprometheus(phase, channel, reset, initValue, sampleTime, base, showStatus)

% Mask Initialization function for Diamond Systems MM and MM-AT D/A driver blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/11/13 20:16:47 $
    
    deviceName  = 'Prometheus';
    vendorName  = 'Diamond';
    description = 'Analog Output';
    maskType    = 'daprometheus';
    
    if phase ~= 2  % assume InitFcn unless phase 2
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType);
        if length(blocks) > 1
            error('Only one Diamond Systems Prometheus D/A block per physical board allowed in a model');
        end
        return
    end

    
    %%% check channel parameter
    if ~isa(channel, 'double') || size(channel, 1) ~= 1 || size(channel, 2) > 4 
        error('Channel parameter must be a vector of length 1 to 4');
    elseif ~all(ismember(channel, [1:4]))
        error('Channel parameter entries must be between 1 and 4');
    end

       
    %%% check reset vector parameter
    if ~isa(reset, 'double')
        error('Reset vector must be of class double');
    end
    if size(reset) == [1 1]
        reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
        error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
    end
    reset = round(reset);
    if ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    end
    
    
    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
        error('Initial value vector must be of class double');
    end
    if size(initValue) == [1 1]
        initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
        error('Initial value vector must be a scalar or have the same number of elements as the Channel vector');
    end

    
    %%% check base parameter
    if ~isa(base, 'char')
        error('Base address parameter must be of class char');
    end
    baseMsg = 'Base address parameter must be a hex address of the form ''0xddd''';
    if ~isa(base, 'char') || length(base) ~= 5 || any(base(1:2) ~= '0x')
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    
    
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    
    for i = 1 : size(channel, 2)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end  
    
    if (showStatus > 0)
        maskDisplay = [maskDisplay, 10, 'port_label(''output'',1,''E'');'];
    end
    
    maskDescription = [deviceName 10 vendorName 10 description];
