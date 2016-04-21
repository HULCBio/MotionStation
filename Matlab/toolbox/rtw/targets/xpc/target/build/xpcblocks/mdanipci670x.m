function [maskdisplay, maskdescription] = ...
    mdanipci670x(phase, boardType, channel, pciSlot)

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $   $Date: 2004/04/08 21:02:48 $

  if phase == 1
    mType = get_param( gcb, 'MaskType' );
    blocks = find_system(bdroot, ...
                         'FollowLinks','on', ...
                         'LookUnderMasks','all', ...
                         'MaskType', mType);
    if length(blocks)>1
      % loop over all blocks and collect information for cross-block checking
      for block=1:length(blocks)
        % PCI-slot (physical board reference
        tmp=evalin('caller', get_param(blocks{block},'pcislot'));
        if length(tmp)==2
          info.pci(block)=tmp(1)*256+tmp(2);
        else
          info.pci(block)=tmp(1);
        end
      end
      % do cross-block checking by using the collected information
      % check for multiple instances using the same physical board
      if length(info.pci)~=length(unique(info.pci))
        error(['Only one instance of this National Instruments D/A block per physical board allowed in a model']);
      end
    end
  end
  
  if phase == 2
    switch boardType
     case 1
      maskdisplay = 'disp(''PCI-6703\nNational Instr.\n';
      description = 'PCI-6703';
      maxChannel  = 16;
     case 2
      maskdisplay = 'disp(''PCI-6704\nNational Instr.\n';
      description = 'PCI-6704';
      maxChannel  = 32;
     case 3
      maskdisplay = 'disp(''PXI-6704\nNational Instr.\n';
      description = 'PXI-6704';
      maxChannel  = 32;
    end
    maskdisplay=[maskdisplay,'Analog Output'');'];
    for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
    end
    maskdescription=[description,10,'National Instr.',10,'Analog Output'];

    if size(channel,1)~=1
      error('Channel Vector must be a row vector');
    end

    chUsed=zeros(1,32);
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
  end
  