
function [rangeOut, baseDec, maskdisplay, maskdescription] = ...
    mdadt2821(phase, channel, range, sampleTime, baseHex, deviceId)

  % MDADT2821 - Mask Initialization for DT2821 series analog output section

  % Copyright 1996-2004 The MathWorks, Inc.

  %%% cross-block checking

  if phase == 1
    block = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'dadt2821');

    if length(block) > 1
      mask = get_param(block, 'MaskValues');
      for i = 1:length(block)
        if strcmp(baseHex, mask{i}{4}) & ~strcmp(gcb, block{i})
          error(['block ' block{i} ' is also using base address ' baseHex]);
        end
      end
    end
  end

  if phase == 2
    switch deviceId
      
     case 1
      board    = 'DT2821 ';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case  2   
      board    = 'DT2821-F-16SE ';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case  3   
      board    = 'DT2821-F-8DI ';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case  4   
      board    = 'DT2821-G-16SE ';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case  5   
      board    = 'DT2821-G-8DI ';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case  6   
      board    = 'DT2823';
      range    = -10;        
      rangeSet = [-10];
      rangeErr = 'range must be -10';        
     case  7   
      error('DT2824-PGH does not support D/A');
     case  8   
      error('DT2824-PGL does not support D/A');
     case  9   
      board    = 'DT2825';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case 10   
      board    = 'DT2827';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     case 11   
      board    = 'DT2828';
      rangeSet = [-10 -5 -2.5 5 10];        
      rangeErr = 'range must be one of the values -10 -5 -2.5 5 10';        
     otherwise
      error('deviceId must be in the range 1-11');
    end


    %%% check channel parameter

    if ~isa(channel, 'double')
      error('Channel Vector parameter must be of class double');
    end

    if size(channel, 1) > 1
      error('Channel Vector parameter must be a row vector');
    end

    channel = round(channel);

    if ~ismember(length(channel), [1 2])
      error('Channel Vector must contain either 1 or 2 elements');
    end

    if ~all(ismember(channel, [1,2]))
      error('Channel Vector elements must be in the range 1-2');
    end


    %%% check range parameter

    if ~isa(range,'double')
      error('Range Vector parameter must be of class double');
    end

    if size(range, 1) > 1
      error('Range Vector parameter must either be a scalar (scalar expansion applies) or a row vector');
    end

    if ~ismember(length(range), [1, length(channel)])
      error('Range Vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements as the Channel Vector parameter');
    end

    % apply scalar expansion if necessary
    if size(range, 1) == 1 & size(range, 2) == 1
      range = range * ones(1, length(channel));
    end

    if ~all(ismember(range, rangeSet)) 
      error(rangeErr); 
    end

    rangeOut = range;

    %%% check sampleTime parameter

    if ~isa(sampleTime, 'double')
      error('Sample Time parameter must be of class double');
    end

    if size(sampleTime, 1) > 1 | size(sampleTime, 2) > 1
      error('Sample Time parameter must be a scalar');
    end


    %%% check baseHex parameter

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

    maskdisplay = sprintf('disp(''%s\\nData Translation\\nAnalog Output'');', board);

    for i = 1:length(channel)
      maskdisplay = sprintf('%s port_label(''input'', %i, ''%i'');', maskdisplay, i, channel(i));
    end         
    %set_param(gcb, 'MaskDisplay', maskdisplay);
    
    maskdescription = [board 10 'Data Translation' 10 'Analog Output'];
    %set_param(gcb, 'MaskDescription', maskdescription);

  end
