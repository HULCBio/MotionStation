
function [baseDec, maskDisplay, maskDescription, reset, initValue] = mdiodsmm(phase, deviceName, direction, channel, sampleTime, baseHex, reset, initValue)

% mdiodsmm - Mask Initialization for Diamond MM series digital I/O

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/09 22:34:03 $


    maxChan    = 8;
    vendorName = 'Diamond';
    
	switch direction
        case 'input'
            prefix = 'di';
            portType = 'output';
            description = 'Digital Input';
        case 'output'
            prefix = 'do';
            portType = 'input';
            description = 'Digital Output';
        otherwise
            error('Bad direction parameter');
	end
        
	switch deviceName
        case 'MM'
            maskType = [prefix 'diamondmm'];
        case 'MM-AT'
            maskType = [prefix 'diamondmmat'];
        case 'MM-16-AT'
            maskType = [prefix 'diamondmm16at'];
        otherwise
            error(['Unknown device ' deviceName]);
	end
	
    if phase == 1  % InitFcn
        baseHex = get_param( gcb, 'baseHex' );
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType, 'baseHex', baseHex);
        if length(blocks) > 1
            error(['Only one Diamond ' deviceName ' ' description ' block per physical board allowed in a model.']);
        end
        return
    end
	
	
	if ~isa(channel, 'double')
      error('Channel Vector parameter must be of class double');
	end
	
	if size(channel, 1) > 1
      error('Channel Vector parameter must be a row vector');
	end
	
	channel = round(channel);
	
	if ~all(ismember(channel, [1:maxChan]))
      error(['Channel vector elements must be in the range 1-' num2str(maxChan)]);
	end
	
    
	if ~isa(sampleTime, 'double')
      error('Sample Time parameter must be of class double');
	end
	
	if size(sampleTime, 1) > 1 | size(sampleTime, 2) > 1
      error('Sample Time parameter must be a scalar');
	end
	
    
	if ~isa(baseHex, 'char')
      error('Base address parameter must be of class char');
	end
	
	baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of 200, 220, 240, ... 3E0';
	
	if length(baseHex) ~= 5 | baseHex(1:2) ~= '0x'
        error(baseMsg);
	end
        
	try
        baseDec = hex2dec(baseHex(3:end));
	catch
        error(baseMsg);
	end
	
	minBase = hex2dec('200');
	maxBase = hex2dec('3e0');
	incBase = hex2dec('020');
	
	if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
	end


	if strcmp(direction, 'output')
        
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
        
        if ~isa(initValue, 'double')
            error('Initial value vector must be of class double');
        end
        if size(initValue) == [1 1]
            initValue = initValue * ones(size(channel));
        elseif ~all(size(initValue) == size(channel))
            error('Initial value vector must be a scalar or have the same number of elements as the Channel vector');
        end
    end
    
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1 : length(channel)
        maskDisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskDisplay, portType, i, channel(i));
    end 
    
    maskDescription = [deviceName 10 vendorName 10 description];
