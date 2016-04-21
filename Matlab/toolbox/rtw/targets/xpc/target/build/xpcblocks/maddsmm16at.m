function [gain, offset, rangeCode, baseDec, maskDisplay, maskDescription] = ...
    maddsmm16at(phase, firstChan, numChans, range, coupling, showStatus, sampleTime, base)

% Mask Initialization function for Diamond Systems MM-16_AT A/D driver blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/09 22:34:06 $
    
    vendorName   = 'Diamond';
    deviceName   = 'MM-16-AT';
    description  = 'Analog Input';
    maskType     = 'addiamondmm16at';
    resolution   = 65536;
    
    if phase ~= 2  % InitFcn
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block per physical board allowed in a model.']);
        end
        return
    end

    switch range
        case 1 
            gain = 1 / resolution * 10;     offset = resolution / 2;      rangeCode = 12;   % 0 to 10V
        case 2 
            gain = 1 / resolution * 5;      offset = resolution / 2;      rangeCode = 13;   % 0 to 5V
        case 3 
            gain = 1 / resolution * 2.5;    offset = resolution / 2;      rangeCode = 14;   % 0 to 2.5V
        case 4 
            gain = 1 / resolution * 1.25;   offset = resolution / 2;      rangeCode = 15;   % 0 to 1.25V
        case 5 
            gain = 2 / resolution * 10;     offset = 0;                   rangeCode =  8;   % -10V to 10V
        case 6 
            gain = 2 / resolution * 5;      offset = 0;                   rangeCode =  9;   % -5V to 5V
        case 7 
            gain = 2 / resolution * 2.5;    offset = 0;                   rangeCode = 10;   % -2.5V to 2.5V
        case 8 
            gain = 2 / resolution * 1.25;   offset = 0;                   rangeCode = 11;   % -1.25V to 1.25V
        case 10 
            gain = 2 / resolution * 0.625;  offset = 0;                   rangeCode =  3;   % -0.625V to 0.65V
        otherwise
            error(['Unsupported range selection: ' num2str(range)]);
    end
   
    switch coupling
        case 1 % single-ended
            maxChan = 16;
        case 2 % double-ended
            maxChan = 8;
    end

    %%% check First channel parameter
    if ~isa(firstChan, 'double') || ~all(size(firstChan, 1) == 1) || ~ismember(firstChan, [1:maxChan])
        error(['First channel must be a scalar between 1 and ' num2str(maxChan)]);
    end
    
    %%% check Number of channels parameter
    if ~isa(numChans, 'double') || ~all(size(numChans, 1) == 1) || ~ismember(firstChan + numChans - 1, [1:maxChan])
        error(['Selected channels must all be scalars between 1 and ' num2str(maxChan)]);
    end
    
    %%% check Sample time parameter
    if ~isa(sampleTime, 'double')
        error('Sample time must be of class double');
    elseif any(size(sampleTime, 1) ~= 1)
        error('Sample time must be a scalar');
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
    for i = 1 : numChans
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, firstChan + i - 1);
    end 
    
    % label the error status port if present
    if showStatus
        maskDisplay = sprintf('%s port_label(''output'', %i, ''E'');', maskDisplay, numChans + 1);
    end
    
    % compute maskDescription
    maskDescription = [deviceName 10 vendorName 10 description];
