function [baseDec, maskdisplay, maskdescription] = mdirtddm6814(phase, port, channel, sampleTime, baseHex)

% mdirtddm6814 - Mask Initialization for RTD DM6814 digital input section

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/10 21:47:03 $

if phase == 1  % InitFcn
    % DIO port A (respectively B, C) and encoder channel 1 (respectively 2, 3) are controlled by the same mode register, 
    % so we need to share information about mode bit settings between encoder, digital input, and digital output blocks. 
    
    port = get_param( gcb, 'port' );
    baseHex = get_param( gcb, 'baseHex' );

    en_channel = char(port - 'A' + '1');
    
    di_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'dirtddm6814', 'port', port, 'baseHex', baseHex);
    do_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'dortddm6814', 'port', port, 'baseHex', baseHex);
    en_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'encrtddm6814', 'channel', en_channel, 'baseHex', baseHex);
    
    if length(di_blocks) > 1
        error('Only one RTD DM6814 digital input block per port per physical board allowed in a model.');
    end

    % masks and complements for mode register regions
    do_mask = 4 + 8;                       
    en_mask = 16 + 32 + 64 + 128;    
    do_comp = bitcmp(do_mask, 8);
    en_comp = bitcmp(en_mask, 8);
    
    % get our UserData
    try
        UserData = get_param(di_blocks{1}, 'UserData');
        mode = UserData.mode ;
    catch
        UserData.mode = 0;
    end
    
    % if there is no digital output block in the model, set the digital output control bits of our UserData.mode accordingly
    if length(do_blocks) == 0
        UserData.mode = bitand(UserData.mode, do_comp);
    end
    
    % if there is no encoder block in the model, set the encoder control bits of our UserData.mode accordingly
    if length(en_blocks) == 0
        UserData.mode = bitand(UserData.mode, en_comp);
    end
    
    % update our UserData
    set_param(di_blocks{1}, 'UserData', UserData); 

    return;
end % InitFcn
    

if phase == 2 % mask init

	portParam = 'output';
	blockType = 'Digital Input';
	maxChan = 8;
	
	% check channel parameter
	if (size(channel, 1) ~= 1) | ~all(ismember(channel, [1:maxChan]))
        error(['Channel vector parameter must be a row vector with entries in the range 1-' num2str(maxChan)]);
	end
	
	% check sampleTime parameter
	if ~isa(sampleTime, 'double') | any(size(sampleTime) ~= 1)
        error('Sample time parameter must be a scalar of class double');
	end
	
	% check base parameter
	if ~isa(baseHex, 'char') | length(baseHex) ~= 5 | baseHex(1:2) ~= '0x'
        error('Base address parameter must a hex address be of the form ''0xddd''');
	end
	try
        baseDec = hex2dec(baseHex(3:end));
	catch
        error('Base address parameter must a hex address be of the form ''0xddd''');
	end
	
	% compute maskdisplay and maskdescription
	maskdisplay = sprintf('disp(''DM6814\\nRTD\\n%s'');', blockType);
	for i = 1:length(channel)
        maskdisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskdisplay, portParam, i, channel(i));
	end         
	maskdescription = ['DM6814' 10 'RTD' 10 blockType];
 
    try
        UserData = get_param(gcb, 'UserData');
        mode = UserData.mode ;
    catch
        % InitFcn hasn't run yet, therefore we must define UserData.mode  so that
        % the call to the driver will succeed so that the number of ports can be fixed.
        % The exact value  is irrelevant since neither mdlStart nor mdlOutputs will
        % be called at this point.
        UserData.mode = 0; 
        set_param(gcb, 'UserData', UserData);       
    end
        
    return
end % mask init
