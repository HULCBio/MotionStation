function [signalScale, velocityScale, baseDec, maskDisplay, maskDescription] = mlvdtapex73ld3(phase, channel, signalScale, velocityScale, dynamicScale, format, wiring, hertz, vrms, sampleTime, base);

% Mask Initialization for the Apex 73LD3 series LVDT/RVDT converters
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/06/06 15:56:50 $

    vendorName  = 'Apex';
    deviceName  = '73LD3 series';
    description = 'LVDT/RVDT';
    maskType    = 'lvdt_apex_73ld3';
    maxChan     = 6;

    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block allowed per physical board (i.e. at the same base address).']);
        end
        return
    end

    %%% check Channel vector parameter
    if ~isa(channel, 'double')
        error('Channel vector parameter must be of class double');
    elseif size(channel, 1) > 1
        error('Channel vector parameter must be a row vector');
    elseif ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector entries must be in the range 1-' num2str(maxChan)]);
    end
     
    %%% check signal scale vector parameter, expanding if necessary
    if ~isa(signalScale, 'double')
        error('Signal scale vector parameter must be of class double');
    elseif ~all(1 <= signalScale) | ~all(signalScale <= 65535) 
        error('Signal scale vector elements must be in the range 1-65535');
    elseif (size(signalScale) == [1 1])
        signalScale = signalScale * ones(size(channel));
    elseif size(signalScale) ~= size(channel)
        error('Signal scale vector must be a scalar or have the same number of elements as the Channel vector');
    end
  
    %%% check velocity scale vector parameter, expanding if necessary
    if ~isa(velocityScale, 'double')
        error('Velocity scale vector parameter must be of class double');
    elseif ~all(9.375 <= velocityScale) | ~all(velocityScale <= 150) 
        error('Velocity scale vector elements must be in the range 9.375-150');
    elseif (size(velocityScale) == [1 1])
        velocityScale = velocityScale * ones(size(channel));
    elseif size(velocityScale) ~= size(channel)
        error('Velocity scale vector must be a scalar or have the same number of elements as the Channel vector');
    end
  
    %%% check excitation frequency parameter
    if ~isa(hertz, 'double')
        error('Excitation frequency parameter must be of class double');
    elseif any(size(hertz) ~= 1) 
        error('Excitation frequency parameter must be a scalar');
    elseif hertz <= 0 
        error('Excitation frequency must be positive');
    end
    
    %%% check excitation voltage parameter
    if ~isa(vrms, 'double')
        error('Excitation voltage parameter must be of class double');
    elseif any(size(vrms) ~= 1) 
        error('Excitation voltage parameter must be a scalar');
    elseif vrms <= 0 
        error('Excitation voltage must be positive');
    end
    
    %%% check sample time parameter
    if ~isa(sampleTime, 'double')
        error('Sample time parameter must be of class double');
    elseif any(size(sampleTime) ~= 1) 
        error('Sample time parameter must be a scalar');
    elseif sampleTime <= 0 
        error('Sample time must be positive');
    end
    
    %%% check base parameter
    if ~isa(base, 'char')
        error('Base address parameter must be of class char');
    end
    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of 000 ... 300, 320, 340 ... 3E0';
    if length(base) ~= 5 | base(1:2) ~= '0x'
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    minBase = hex2dec('000');
    maxBase = hex2dec('3e0');
    incBase = hex2dec('020');
    if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
    end
    
    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
   
    maskDescription = [deviceName 10 vendorName 10 description];
