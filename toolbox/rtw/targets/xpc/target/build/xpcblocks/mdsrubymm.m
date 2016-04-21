function [maskdisplay,base,reset,initValue] = mdsrubymm( phase, channel, baseaddress, reset, initValue )
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');
    
    baseaddr = get_param( gcb, 'baseaddress' );
    blocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','dsRubyMM-daout','baseaddress', baseaddr);
    if length(blocks) > 1
      error('Only one Ruby-MM DA output block allowed in a model for any single board.');
    end
  end
  
  if phase == 2  % called as mask init function
    %disp('Called as mask init function');
    maskdisplay = 'disp(''Ruby-MM\nDiamond\nAnalog Output'');';
    
    lth = length(channel);
    if lth < 1 | lth > 8
      error('The number of output channels must be in the range 1..8');
    end
    test = zeros(1,8);
    inport = '';
    for i = 1:length(channel)
      chan = channel(i);
      if chan < 1 | chan > 8
        error('Output channels must be in the range 1..8');
      end
      if test(chan)
        error(['Attempting to use output channel ',num2str(chan),' more than once.']);
      end
      test(chan) = 1;
      inport = [inport, ' port_label(''input'',',num2str(i),',''', num2str(chan),''');'];
    end
    maskdisplay = [maskdisplay, inport ];

    base = hex2dec(baseaddress(3:end));
    minaddr = 512;   % 0x200
    maxaddr = 960;   % 0x3c0
    addrinc = 64;    % 0x40
    if base < minaddr
      error('Use a base address above 0x200');
    end
    if base > maxaddr
      error('Use a base address below 0x3c0');
    end
    if mod( base, addrinc ) ~= 0
      error('The base address must be a multiple of 0x40');
    end
    
    %%% check reset vector parameter
    if ~isa(reset, 'double')
      error('Reset vector parameter must be of class double');
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

    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
      error('Initial value vector parameter must be of class double');
    end
    if size(initValue) == [1 1]
      initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
      error('Initial value must be a scalar or have the same number of elements as the Channel vector');
    end
    initValue = round(initValue);
  end


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/08 21:02:55 $
