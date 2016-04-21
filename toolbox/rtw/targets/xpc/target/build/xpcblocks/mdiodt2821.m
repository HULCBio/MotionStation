
function [baseDec, maskdisplay, maskdescription] = ...
    mdiodt2821(phase, port, channel, sampleTime, baseHex, deviceId, direction)

  % MDIODT2821 - Mask Initialization for DT2821 series digital input or output section, depending upon the value
  % of the direction parameter ('input' or 'output')


  % Copyright 1996-2004 The MathWorks, Inc.
  %   $Revision: 1.2.4.1 $  $Date: 2004/03/02 03:04:47 $


  %%% cross-block checking
  if phase == 1
    block = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'diodt2821');

    if length(block) > 1
      baseStr = lower(baseHex);
      portStr = num2Str(port);
      mask = get_param(block, 'MaskValues');
      
      for i = 1:length(block)
        if ~strcmp(gcb, block{i}) & strcmp(portStr, mask{i}{1}) & strcmp(baseStr, lower(mask{i}{4}))
          error(['block ' block{i} ' is also using port ' portStr ' of the board with base address ' baseStr]);
        end
      end
    end
  end

  if phase == 2
    switch deviceId
      
     case 1
      board = 'DT2821';
     case  2   
      board = 'DT2821-F-16SE';
     case  3   
      board = 'DT2821-F-8DI';
     case  4   
      board = 'DT2821-G-16SE';
     case  5   
      board = 'DT2821-G-8DI';
     case  6   
      board = 'DT2823';
     case  7   
      board = 'DT2824-PGH';
     case  8   
      board = 'DT2824-PGL';
     case  9   
      board = 'DT2825';
     case 10   
      board = 'DT2827';
     case 11   
      board = 'DT2828';
     otherwise
      error('deviceId must be in the range 1-11');
    end


    %%% check port parameter

    if ~isa(port, 'double')
      error('Port parameter must be of class double');
    end

    if size(port, 1) > 1 | size(port, 2) > 1
      error('Port parameter must be a scalar');
    end

    port = round(port);

    if ~ismember(port, [1,2])
      error('Port parameter must be 1 or 2');
    end


    %%% check channel parameter

    if ~isa(channel, 'double')
      error('Channel Vector parameter must be of class double');
    end

    if size(channel, 1) > 1
      error('Channel Vector parameter must be a row vector');
    end

    channel = round(channel);

    if ~isempty( find(channel < 1)) | ~isempty(find(channel > 8) )
      error('Channel Vector elements must be in the range 1-8');
    end


    %%% check sampleTime parameter

    if ~isa(sampleTime, 'double')
      error('Sample Time parameter must be of class double');
    end

    if size(sampleTime, 1) > 1 | size(sampleTime, 2) > 1
      error('Sample Time parameter must be a scalar');
    end


    %%% check base parameter

    if ~isa(baseHex, 'char')
      error('Base address parameter must be of class char');
    end

    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of the hex addresses 200, 220, 240, ... 3E0';

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


    % compute maskdisplay and maskdescription

    switch direction
     case 'input'
      portparam = 'output';
      blocktype = 'Digital Input';
     case 'output'
      portparam = 'input';
      blocktype = 'Digital Output';
     otherwise
      error('bad direction parameter');
    end

    maskdisplay = sprintf('disp(''%s\\nData Translation\\n%s'');', board, blocktype);

    for i = 1:length(channel)
      maskdisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskdisplay, portparam, i, channel(i));
    end         
    %set_param(gcb, 'MaskDisplay', maskdisplay);
    
    maskdescription = [board 10 'Data Translation' 10 blocktype];
    %set_param(gcb, 'MaskDescription', maskdescription);

  end
