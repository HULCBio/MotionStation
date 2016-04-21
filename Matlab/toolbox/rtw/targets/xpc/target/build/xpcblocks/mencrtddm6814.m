function [baseDec, maskdisplay, maskdescription] = mencrtddm6814(phase, channel, initValue, reset, sampleTime, baseHex)

% mencrtddm6814 - Mask Initialization for RTD DM6814 encoder output section

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/10 21:47:08 $

if phase == 1  % InitFcn
    % DIO port A (respectively B, C) and encoder channel 1 (respectively 2, 3) are controlled by the same mode register, 
    % so we need to share information about mode bit settings between encoder, digital input, and digital output blocks. 

    channel = get_param( gcb, 'channel' );
    baseHex = get_param( gcb, 'baseHex' );
    
    port = char(channel - '1' + 'A');
    
    di_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'dirtddm6814', 'port', port, 'baseHex', baseHex);
    do_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'dortddm6814', 'port', port, 'baseHex', baseHex);
    en_blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'encrtddm6814', 'channel', channel, 'baseHex', baseHex);
    
    if length(en_blocks) > 1
        error('Only one RTD DM6814 encoder block per channel per physical board allowed in a model.');
    end
    
    if length(di_blocks) == 0 & length(do_blocks) == 0
        noDio = 1;
    else
        noDio = 0;
    end
    
    % masks and complements for mode register regions
    do_mask = 4 + 8;                       
    en_mask = 16 + 32 + 64 + 128;    
    do_comp = bitcmp(do_mask, 8);
    en_comp = bitcmp(en_mask, 8);
    
    % compute the en_mode bits, i.e. D4-D7
    reset = strcmp( get_param(gcb, 'reset'), 'on' );
    en_mode = 32 + 64 + 128 * reset; % enable encoder  
    
  % set the encoder control bits of our UserData.mode
    try
        UserData = get_param(en_blocks{1}, 'UserData');
        UserData.mode = bitand(UserData.mode, en_comp);
        UserData.mode = bitor(UserData.mode, en_mode);
    catch
        UserData.mode = en_mode;
    end
    
    % if there is no digital output block in the model, set the digital output control bits of our UserData.mode accordingly
    if length(do_blocks) == 0
        UserData.mode = bitand(UserData.mode, do_comp);
    end 
    
    % record in our UserData whether the model contains any digital I/O blocks
    UserData.noDio = noDio;
    
    % update our UserData 
    set_param(en_blocks{1}, 'UserData', UserData); 
   
    % if there is a digital input block in the model, update its UserData en_mode bits
    if length(di_blocks) == 1
        try
            UserData = get_param(di_blocks{1}, 'UserData');
            UserData.mode = bitand(UserData.mode, en_comp);
            UserData.mode = bitor(UserData.mode, en_mode);
        catch
            UserData.mode = en_mode;
        end
        set_param(di_blocks{1}, 'UserData', UserData); 
    end
   
    % if there is a digital output block in the model, update its UserData en_mode bits
    if length(do_blocks) == 1
        try
            UserData = get_param(do_blocks{1}, 'UserData');
            UserData.mode = bitand(UserData.mode, en_comp);
            UserData.mode = bitor(UserData.mode, en_mode);
        catch
            UserData.mode = en_mode;
        end
        set_param(do_blocks{1}, 'UserData', UserData); 
    end
    
    return;
end % InitFcn


if phase == 2 % mask init 

	% check initValue parameter
	if any(size(initValue) ~= 1) | ~ismember(initValue, [0:65535])
        error('Counter initial value parameter must be a scalar integer in the range 0-65535');
	end
	
	% check sampleTime parameter
	if ~isa(sampleTime, 'double') | any(size(sampleTime) ~= 1)
        error('Sample Time parameter must be a scalar of class double');
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
	maskdisplay = sprintf('disp(''DM6814\\nRTD\\nIncremental Encoder'');');
    maskdisplay = sprintf('%s port_label(''output'', 1, ''%i'');', maskdisplay, channel);
	maskdescription = ['DM6814' 10 'RTD' 10 'Incremental Encoder'];

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
    
    return;
end % mask init