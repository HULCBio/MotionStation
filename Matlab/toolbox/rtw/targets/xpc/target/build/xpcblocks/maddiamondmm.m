function [gain, offset, baseDec, maskDisplay, maskDescription] = maddiamondmm(phase, numChans, range, coupling, showStatus, sampleTime, base)

% Mask Initialization function for Diamond Systems MM A/D driver blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/10/25 16:34:05 $
    
    vendorName   = 'Diamond';
    deviceName   = 'MM';
    description  = 'Analog Input';
    maskType     = 'addiamondmm';
    resolution   = 4096;
    
    if phase ~= 2  % InitFcn
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error('Only one Diamond Systems MM A/D block per physical board allowed in a model.');
        end
        return
    end

    custom = 5/20; % VFS for default custom gain of 20
    
    switch range
        case 1 
            gain = 1 / resolution * 10;      offset = 0;        % 0 to 10V
        case 2 
            gain = 1 / resolution * 5;       offset = 0;        % 0 to 5V
        case 3 
            gain = 1 / resolution * 2;       offset = 0;        % 0 to 2V
        case 4 
            gain = 1 / resolution * 1;       offset = 0;        % 0 to 1V
        case 5 
            gain = 1 / resolution * custom;  offset = 0;        % 0 to custom
        case 6 
            gain = 2 / resolution * 10;      offset = 10;       % -10 to 10V
        case 7 
            gain = 2 / resolution * 5;       offset = 5;        % -5 to 5V
        case 8 
            gain = 2 / resolution * 2.5;     offset = 2.5;      % -2.5 to 2.5V
        case 9 
            gain = 2 / resolution * 1;       offset = 1;        % -1 to 1V
        case 10 
            gain = 2 / resolution * 0.5;     offset = 0.5;      % -0.5 to 0.5V
        case 11 
            gain = 2 / resolution * custom;  offset = custom;   % -custom to custom
    end
   
    switch coupling
        case 1 % single-ended
            maxChan = 16;
        case 2 % double-ended
            maxChan = 8;
    end

    %%% check Number of channels parameter
    if ~isa(numChans, 'double')
        error('Number of channels must be of class double');
    elseif any(size(numChans, 1) ~= 1)
        error('Number of channels must be a scalar');
    elseif ~ismember(numChans, [1:maxChan])
        error(['Number of channels must be between 1 and ' num2str(maxChan)]);
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
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, i);
    end 
    
    % label the error status port if present
    if showStatus
        maskDisplay = sprintf('%s port_label(''output'', %i, ''E'');', maskDisplay, numChans + 1);
    end
    
    % compute maskDescription
    maskDescription = [deviceName 10 vendorName 10 description];
