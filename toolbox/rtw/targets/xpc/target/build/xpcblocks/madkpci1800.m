function madkpci1800(phase, channel, range, coupling, ref, boardType)

% MADKPCI1800 - InitFcn and Mask Initialization for KPCI-1800 series A/D section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.3.4.1 $ $Date: 2004/03/02 03:04:04 $

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
	info.pci(block)= str2num(maskValues{block}{5});
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
      supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
      maxChannel=64; 
     case 2
      maskdisplay='disp(''KPCI-1801HC\nKeithley\n';
      description='KPCI-1801HC';
      supRange=[-5, -1, -0.1, -0.02, 5, 1, 0.1, 0.02];
      supRangeStr='-5, -1, -0.1, -0.02, 5, 1, 0.1, 0.02';
      maxChannel=64; 
    end
   
    maskdisplay=[maskdisplay,'Analog Input'');'];
    for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
    end         
    set_param(gcb,'MaskDisplay',maskdisplay);

    maskdescription=[description,10,'Keithley',10,'Analog Input'];
    set_param(gcb,'MaskDescription',maskdescription);

    chUsed=zeros(1,64);

    if size(channel,1)~=1
      error('Channel Vector must be a row vector');
    end
    if size(range,1)~=1
      error('Range Vector must be a row vector');
    end
    if size(coupling,1)~=1
      error('Coupling Vector must be a row vector');
    end

    % if the parameter is a scalar, apply scalar expansion
    if size(range,1)==1 & size(range,2)==1
      range= range * ones(1,length(channel));
    end

    % if the parameter is a scalar, apply scalar expansion
    if size(coupling,1)==1 & size(coupling,2)==1
      coupling= coupling * ones(1,length(channel));
    end

    if length(range)~=length(channel)
      error('Range Vector must have the same numbers of elements as the Channel Vector');
    end

    if length(coupling)~=length(channel)
      error('Coupling Vector must have the same numbers of elements as the Channel Vector');
    end

    for i=1:length(channel)
      chan=round(channel(i));
      rng=range(i);
      cpl=round(coupling(i));
      if ~ismember(cpl,[0,1])
	error('Coupling Vector elements have to be either 0 (single-ended) or 1 (differential)');
      end
      if ~ismember(rng,supRange)
	error(['Range Vector elements have to be in the range: ',supRangeStr]);
      end
      if cpl<1
	if chan < 1 | chan > maxChannel
	  error(['Channel Vector elements have to be in the range: 1..',num2str(maxChannel)]);
	end
	if chUsed(chan)
	  error(['channel ',num2str(chan),' already in use (maybe needed for differential coupling mode)']);
	else
	  chUsed(chan)=1;
	end
      else
	if chan < 1 | chan > maxChannel/2
	  error(['for differential coupling mode the Channel Vector element has to be in the range: 1..',num2str(maxChannel/2)]);
	end
	if chUsed(chan)
	  error(['channel ',num2str(chan),' already in use']);
	else
	  chUsed(chan)=1;
	  if chUsed(chan+maxChannel/2)
            error(['channel ',num2str(chan+maxChannel/2),' already in use (needed for differential coupling mode)']);
	  else
            chUsed(chan+maxChannel/2)=1;
	  end
	end
      end
    end
  end
  




