function [baseDec, maskDisplay, maskDescription] = maddiamondmm32(phase, configuration, firstChan, numChans, range, base)

% maddiamondmmx - Mask Initialization function for Diamond Systems MM-32 driver blocks
% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2004/04/08 21:02:39 $
    
    vendorName   = 'Diamond';
    deviceName   = 'MM-32';
    description  = 'Analog Input';
    maskType     = 'addiamondmm32';
    
    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one Diamond Systems MM-32 A/D block per physical board allowed in a model - each block of this type must have a distinct ISA address.');
        end
        return
    end

    switch configuration
        case 1 % 0-31 SE
            maxChan = 32;
        case 2 % 0-15 DI
            maxChan = 16;
        case 3 % 0-7 SE, 8-15 DI, 16-23 SE 
            maxChan = 24;
        otherwise
            disp('bad configuration value');
    end

    %%% check First channel parameter
    if ~isa(firstChan, 'double')
        error('First channel number must be of class double');
    elseif any(size(firstChan, 1) ~= 1)
        error('First channel number must be a scalar');
    elseif ~ismember(firstChan, [1:maxChan])
        error(['First channel number must be between 1 and ' num2str(maxChan)]);
    end
    
    %%% check Number of channels parameter
    if ~isa(numChans, 'double')
        error('Number of channels must be of class double');
    elseif any(size(numChans, 1) ~= 1)
        error('Number of channels must be a scalar');
    elseif ~ismember(numChans, [1:maxChan])
        error(['Number of channels must be between 1 and ' num2str(maxChan)]);
    end
  
    if firstChan + numChans - 1 > maxChan
        error(['Selected first channel and number of channels yields a channel number exceeding ' num2str(maxChan)]);
    end

    %%% check base parameter
    if ~isa(base, 'char')
        error('Base address parameter must be of class char');
    end
    baseMsg = 'Base address parameter must be a hex address of the form ''0xddd''';
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
    for i = 1 : numChans
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, firstChan + i - 1);
    end         
    maskDescription = [deviceName 10 vendorName 10 description];
