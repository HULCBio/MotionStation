function [maskDisplay, maskDescription, reset, initValue, baseDec] = mdartddm6430( phase, channel, reset, initValue, base )

    %%% board-specific variables

    vendorName   = 'RTD';
    deviceName   = 'DM6430';
    description  = 'Analog Output';
    maskType     = 'dartddm6430';

    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one RTD DM6430 analog output block per physical board allowed in a model.');
        end
        return
    end
    
    
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:2]))
        error('Channel vector entries must be 1 or 2');
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
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
    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is a hex address';
    if length(base) ~= 5 | base(1:2) ~= '0x'
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
   
    
    % compute maskDisplay and maskDescription
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
        maskDisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskDisplay, i, channel(i));
    end         
    maskDescription = [deviceName 10 vendorName 10 description];

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:02:49 $
