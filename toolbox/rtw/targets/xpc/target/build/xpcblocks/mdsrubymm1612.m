function [maskDisplay, maskDescription, range, reset, initValue, baseDec] = mdsrubymm1612( phase, channel, range1, range2, reset, initValue, base )

    %%% board-specific variables

    vendorName   = 'Diamond';
    deviceName   = 'Ruby-MM-1612';
    description  = 'Analog Output';
    maskType     = 'dadsrubymm1612';

    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one Ruby-MM-1612 analog output block per physical board allowed in a model.');
        end
        return
    end
    
    
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:16]))
        error('Channel vector entries must be in the range 1-16');
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
     
    %%% check consistency of range1 and range2 parameters and compute output range vector
    %%% we assume the popup entries are -2.5, -5, -10, 2.5, 5, 10 in that order
    type = [1 1 -1 1 1 -1];  
    code = [-2.5 -5 -10 2.5 5 10];
    if type(range1) * type(range2) == -1
        error('If the range of one bank is -2.5V to 2.5V, -5V to 5V, 0 to 2.5V or 0 to 5V, then then range of the other bank cannot be either -10 to 10V or 0 to 10V');
    end
    bankrange = [code(range1) code(range2)];
    bank = floor((channel-1) / 8) + 1;
    range = bankrange(bank);
    
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
    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of the hex addresses 100, 110, ... 3e0';
    if length(base) ~= 5 | base(1:2) ~= '0x'
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    minBase = hex2dec('100');
    maxBase = hex2dec('3e0');
    incBase = hex2dec('010');
    if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
    end
   
    
    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
   
    maskDescription = [deviceName 10 vendorName 10 description];

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/08 21:02:56 $
