
function [rangeOut, baseDec, maskdisplay, maskdescription] = ...
    maddt2821(phase, channel, gain, range, coupling, sampleTime, baseHex, deviceId)

% MADDT2821 - Mask Initialization for DT2821 series analog input section

% Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/03/02 03:04:03 $

%%% cross-block checking

  if phase == 1
    block = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'addt2821');
    
    if length(block) > 1
      mask = get_param(block, 'MaskValues');
      for i = 1:length(block)
        if strcmp(baseHex, mask{i}{6}) & ~strcmp(gcb, block{i})
          error(['block ' block{i} ' is also using base address ' baseHex]);
        end
      end
    end
  end
  
  if phase == 2
    rangeTable1 = [-10 10];
    rangeTable2 = [-10 -5  10];

    switch deviceId
      
     case 1
      board            = 'DT2821 ';
      maxChannel       = 16 / coupling;   % SE or DI
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable1(range);
      
     case  2   
      board            = 'DT2821-F-16SE ';
      maxChannel       = 16;              % SE only
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable1(range);
      
     case  3   
      board            = 'DT2821-F-8DI ';
      maxChannel       = 8;               % DI only
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable1(range);
      
     case  4   
      board            = 'DT2821-G-16SE ';
      maxChannel       = 16;              % SE only
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable2(range);
      
     case  5   
      board            = 'DT2821-G-8DI ';
      maxChannel       = 8;               % DI only
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable2(range);
      
     case  6   
      board            = 'DT2823';
      maxChannel       = 4;               % DI only
      supportedGain    = [1];
      supportedGainStr = '1';
      rangeOut         = -10;
      
     case  7   
      board            = 'DT2824-PGH';
      maxChannel       = 16 / coupling;   % SE or DI
      supportedGain    = [1,2,4,8];
      supportedGainStr = '1, 2, 4, 8';
      rangeOut         = rangeTable1(range);
      
     case  8   
      board            = 'DT2824-PGL';
      maxChannel       = 16 / coupling;   % SE or DI
      supportedGain    = [1,10,100,500];
      supportedGainStr = '1, 10, 100, 500';
      rangeOut         = rangeTable1(range);
      
     case  9   
      board            = 'DT2825';
      maxChannel       = 16 / coupling;   % SE or DI
      supportedGain    = [1,10,100,500];
      supportedGainStr = '1, 10, 100, 500';
      rangeOut         = rangeTable1(range);
      
     case 10   
      board            = 'DT2827';
      maxChannel       = 4;               % DI only
      supportedGain    = [1];
      supportedGainStr = '1';
      rangeOut         = -10;
      
     case 11   
      board            = 'DT2828';
      maxChannel       = 1;               % 4 SE chans, but driver supports only 1
      supportedGain    = [1];
      supportedGainStr = '1';
      rangeOut         = rangeTable1(range);
      
     otherwise
      error('deviceId must be in the range 1-11');
    end



    %%% check channel parameter

    if ~isa(channel, 'double')
      error('Channel vector parameter must be of class double');
    end

    if size(channel, 1) > 1
      error('Channel vector parameter must be a row vector');
    end

    channel = round(channel);

    if any(channel < 1) | any(channel > maxChannel)
      error(['Channel vector elements must be in the range 1..' num2str(maxChannel)]);
    end


    %%% check gain parameter

    if ~isa(gain,'double')
      error('Gain vector parameter must be of class double');
    end

    if size(gain, 1) > 1
      error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector');
    end

    % apply scalar expansion if necessary
    if size(gain, 1) == 1 & size(gain, 2) == 1
      gain = gain * ones(1, length(channel));
    end

    if length(gain) ~= length(channel) 
      error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements as the Channel vector parameter');
    end
    
    gain= round(gain);

    if ~all(ismember(gain,supportedGain))
      error(['Gain vector elements must be one of: ' supportedGainStr]);
    end
    

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

    maskdisplay = sprintf('disp(''%s\\nData Translation\\nAnalog Input'');', board);

    for i = 1:length(channel)
      maskdisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskdisplay, i, channel(i));
    end         
    
    maskdescription = [board 10 'Data Translation' 10 'Analog Output'];

  end