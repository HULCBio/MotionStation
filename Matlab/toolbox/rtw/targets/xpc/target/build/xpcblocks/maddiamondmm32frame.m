function [freq12, count1, count2, baseDec, maskDisplay, maskDescription] = ...
	maddiamondmm32frame(phase, configuration, firstChan, numChans, numScans, scanInterval, scanTime, base);

% maddiamondmm32frame - Mask Initialization function for Diamond Systems MM-32 frame-based A/D driver blocks
% Copyright 2003 The MathWorks, Inc.
    
    if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
        return
    end

    vendorName   = 'Diamond';
    deviceName   = 'MM-32 Frame';
    description  = 'Analog Input';
    maskType     = 'addiamondmm32';
    maxFrameSize = 512;
    
    if phase ~= 2  % assume InitFcn unless phase 2
        base = get_param( gcb, 'base' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'base', base);
        if length(blocks) > 1
            error(['Only one ' vendorName ' ' deviceName ' ' description ' block per physical board allowed in a model - duplicate blocks must have distinct ISA addresses.']);
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
    if ~isa(firstChan, 'double') || ~all(size(firstChan, 1) == 1) || ~ismember(firstChan, [1:maxChan])
        error(['First channel number must be a number between 1 and ' num2str(maxChan)]);
    end
    
    %%% check Number of channels parameter
    if ~isa(numChans, 'double') || ~all(size(numChans, 1) == 1) || ~ismember(numChans, [1:maxChan])
        error(['Number of channels must be a number between 1 and ' num2str(maxChan)]);
    end
    
    %%% check parity of a FIFO's worth of data
    if mod(numChans * numScans, 2) == 1
        error('At least one of the fields "Number of channels" or "Number of scans per frame" must be even');
    end
    
    maxCount = 2^16 - 1;
    maxScanTime = maxCount^2 * 1e-5;

    if scanTime <= maxCount^2 * 1e-7
        freq12 = 0; 
        baseTime = 1e-7;
    elseif scanTime <= maxScanTime
        freq12 = 1; 
        baseTime = 1e-5;
    else
        error(['Interval between scans cannot exceed ' num2str(maxScanTime)]);
    end

    scanIntervalMicrosec = 5e-6 * scanInterval;
    minScanTime = numChans * scanIntervalMicrosec;  
    
    if scanTime < minScanTime
        error(['Interval between scans cannot be less than ' num2str(minScanTime)]);
    end
        
    [count2, count1] = approx(scanTime / baseTime, maxCount, 0.0001);
    
    actualScanTime = count1 * count2 * baseTime;
    actualSampleTime = actualScanTime * numScans;

    %%% check base parameter
    baseMsg = 'Base address parameter must be a hex address of the form ''0xddd''';
    if ~isa(base, 'char') || length(base) ~= 5 || ~all(base(1:2) == '0x')
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

    
    % Given real x and max satisfying 0 < max and 0 <= x <= max^2, find
	% (if possible) integers a and b in [0:max] so that ab closely approximates x, 
	% i.e. so that (x - |x - ab|) / x is less than a prescribed precision.
    %
	function [a, b] = approx(x, max, precision)
        error = realmax;
        tolerance = x * precision;
        for i = [ceil(x/max) : floor(sqrt(x))]
            for j = [floor(x/i) : ceil(x/i)]
                d = abs(x - i * j);
                if d < error
                    a = i;
                    b = j;
                    error = d;
                    if error <= tolerance
                        return;
                    end
                end
            end
        end
        error('error approximating requested scan time');

    
    
