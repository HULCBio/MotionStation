function [reset, initValue] = mdiokpci1800(phase, channel, ref, direct, boardType, reset, initValue)

% MDIOKPCI1800 - InitFcn and Mask Initialization for KPCI-1800 series digital I/O section

% The final two parameters (reset and initValue) are used only for digital output  

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.4.4.1 $ $Date: 2004/03/02 03:04:48 $

  if phase == 1
    % collect information from all blocks having the same MaskType
    blocks=find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', get_param( gcb, 'MaskType' ) );
    % if only one instance is found skip next step
    if length(blocks)>1
      % loop over all blocks and collect all information for cross-block checking
      maskValues= get_param(blocks,'MaskValues');
      info.pci= zeros(1,length(blocks));
      for block=1:length(blocks)
        % PCI-slot (physical board reference)
	info.pci(block)= str2num(maskValues{block}{3});
      end
      % do cross-block checking by using the collected information
      % check for multiple instances using the same physical board
      if length(info.pci)~=length(unique(info.pci))
        error('only one instance of this block supported per physical board');
      end
    end
  end
  
  if phase == 2
    switch boardType 
     case 1	
      maskdisplay='disp(''KPCI-1802HC\nKeithley\n';
      description='KPCI-1802HC';
     case 2
      maskdisplay='disp(''KPCI-1801HC\nKeithley\n';
      description='KPCI-1801HC';
    end

    if direct==1
      maskdisplay=[maskdisplay,'Digital Input'');'];
      maskdescription=[description,10,'Keithley',10,'Digital Input'];
      for i=1:length(channel)
	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
      end   
      maxChannel=4; 
    elseif direct==2
      maskdisplay=[maskdisplay,'Digital Output'');'];
      maskdescription=[description,10,'Keithley',10,'Digital Output'];
      for i=1:length(channel)
	maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
      end   
      maxChannel=8;
    end
    set_param(gcb,'MaskDisplay',maskdisplay);
    set_param(gcb,'MaskDescription',maskdescription);

    chUsed=zeros(1,8);

    if size(channel,1)~=1
      error('Channel Vector must be a row vector');
    end

    for i=1:length(channel)
      chan=round(channel(i));
      if chan < 1 | chan > maxChannel
	error(['Channel Vector elements have to be in the range: 1..',num2str(maxChannel)]);
      end
      if chUsed(chan)
	error(['channel ',num2str(chan),' already in use ']);
      else
	chUsed(chan)=1;
      end
    end

    if direct == 2 % if output, check reset and initValue parameters

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

      if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
      end
      if size(initValue) == [1 1]
        initValue = initValue * ones(size(channel));
      elseif ~all(size(initValue) == size(channel))
        error('Initial value must be a scalar or have the same number of elements as the Channel vector');
      end
      initValue = round(initValue);
      if ~all(ismember(initValue, [0 1]))
        error('Initial value vector elements must be 0 or 1');
      end

    end
  end
