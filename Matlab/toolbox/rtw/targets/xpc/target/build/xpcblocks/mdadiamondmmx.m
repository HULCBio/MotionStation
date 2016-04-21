function [maskdisplay, maskdescription, reset, initValue] = ...
    mdadiamondmmx(phase, boardType, channel, baseAddress, reset, initValue)

% MDADIAMONDMMX - Mask Initialization function for Dimaond Systems MM driver blocks

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.6.2.1 $ $Date: 2004/03/02 03:04:40 $

  if phase == 1
    switch boardType
     case 1
      baseAddress = get_param( gcb, 'baseaddress' );
      blocks=find_system(bdroot, ...
                         'FollowLinks','on', ...
                         'LookUnderMasks','all', ...
                         'MaskType','dadiamondmm32', ...
                         'baseaddress',baseAddress);
      if length(blocks)>1
        error('Only one instance of the Diamond Systems MM-32 D/A block per physical board allowed in a model');
      end
    end
  end
  
  if phase == 2
    switch boardType
     case 1  
      maskdisplay='disp(''MM-32\nDiamond\n';
      description='MM-32';
      maxChannel=4;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10,-5, 10, 5';
    end
    maskdisplay=[maskdisplay,'Analog Output'');'];
    for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
    end
    maskdescription=[description,10,'Diamond Systems',10,'Analog Output'];
    

    if size(channel,1)~=1
      error('Channel Vector must be a row vector');
    end
    
    chUsed=zeros(1,4);
    for i=1:length(channel)
      chan=round(channel(i));
      if chan < 1 | chan > maxChannel
        error(['Channel Vector elements have to be in the range: 1..',num2str(maxChannel)]);
      end
      if chUsed(chan)
        error(['channel ',num2str(chan),' already in use']);
      else
        chUsed(chan)=1;
      end
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
  end
  