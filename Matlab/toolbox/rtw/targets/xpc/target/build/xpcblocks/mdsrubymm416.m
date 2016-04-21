function [maskDisplay, maskDescription, range, reset, initValue, baseDec] = mdsrubymm416( phase, channel, range, reset, initValue, base )

    %%% board-specific variables

    vendorName   = 'Diamond';
    deviceName   = 'Ruby-MM-416';
    description  = 'Analog Output';
    maskType     = 'dadsrubymm416';

    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one Ruby-MM-416 analog output block per physical board allowed in a model.');
        end
        return
    end
    
    
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:4]))
        error('Channel vector entries must be in the range 1-4');
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
     
    %%% check range vector parameter
    if ~isa(range, 'double')
        error('Range vector parameter must be of class double');
    elseif ~all(ismember(range, [-10 -5 10]))
        error('Range vector elements must be chosen from the values -5 -10 10');
    elseif (size(range) == [1 1])
        range = range * ones(size(channel));
    elseif size(range) ~= size(channel)
        error('Range vector must be a scalar or have the same number of elements as the Channel vector');
    end

    %%% check reset vector parameter
    if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
    elseif size(reset) == [1 1]
        reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
        error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
    end
    if ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    end

    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
    elseif size(initValue) == [1 1]
        initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
        error('Initial value must be a scalar or have the same number of elements as the Channel vector');
    end

    %%% check base parameter
    if ~isa(base, 'char')
        error('Base address parameter must be of class char');
    end
    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of 100, 140, ... 3C0';
    if length(base) ~= 5 | base(1:2) ~= '0x'
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    minBase = hex2dec('100');
    maxBase = hex2dec('3c0');
    incBase = hex2dec('040');
    if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
    end
   
    
    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/06/17 12:13:28 $
