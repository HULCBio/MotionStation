function [maskDisplay, maskDescription, baseDec] = mpwmrtddm6816( phase, channel, divisor, base )

    %%% board-specific variables

    vendorName   = 'RTD';
    deviceName   = 'DM6816';
    description  = 'PWM';
    maskType     = 'pwmrtddm6816';

    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one RTD DM6816 analog output block per physical board allowed in a model.');
        end
        return
    end
    
    
    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:9]))
        error('Channel vector entries must be in the range 1-9');
    elseif length(channel) ~= length(unique(channel))
        error('Channel vector entries must be distinct');
    end
     

    %%% check Frequency divisor parameter
    if ~isa(divisor, 'double')
        error('Frequency divisor parameters must be of class double');
    elseif ~all(ismember(divisor, [2:65535]))
        error('Frequency divisors must be in the range 2-65535');
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
%   $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:03:09 $
