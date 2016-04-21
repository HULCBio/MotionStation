function [maskdisplay, maskdescription, oreset, oinitval]= ...
    mdanipci671x(when, boardType, channel, reset, initval, pciSlot)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2003/09/14 13:58:33 $

switch boardType
 case 1
  maskdisplay = 'disp(''PCI-6713\nNational Instr.\n';
  description = 'PCI-6713';
  maxChannel  = 8;
  mType       = 'danipci6713';
 case 2
  maskdisplay = 'disp(''PXI-6713\nNational Instr.\n';
  description = 'PXI-6713';
  maxChannel  = 8;
  mType       = 'danipxi6713';
 case 3
  maskdisplay = 'disp(''PCI-6711\nNational Instr.\n';
  description = 'PCI-6711';
  maxChannel  = 4;
  mType       = 'danipci6711';
% case 4
%  maskdisplay = 'disp(''PXI-6711\nNational Instr.\n';
%  description = 'PXI-6711';
%  maxChannel  = 4;
%  mType       = 'danipxi6711';
end

if when == 1
  blocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all', ...
                       'MaskType', mType);
  if length(blocks)>1
    % loop over all blocks and collect all information for cross-block checking
    for block=1:length(blocks)
      % PCI-slot (physical board reference
      tmp=eval(get_param(blocks{block},'pcislot'));
      if length(tmp)==2
        info.pci(block)=tmp(1)*256+tmp(2);
      else
        info.pci(block)=tmp(1);
      end
    end
    % do cross-block checking by using the collected information
    % check for multiple instances using the same physical board
    if length(info.pci)~=length(unique(info.pci))
      error(['Only one instance of the National Instruments ',description,' D/A block per physical board allowed in a model']);
    end
  end
end

if when == 2
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

  rlength = length(reset);
  clength = length(channel);
  if( rlength == 1 && clength > 1 )
    oreset = ones( 1, clength ) * reset;
  else
    oreset = reset;
  end
  if( length( oreset ) ~= clength )
    error(['Length of the reset vector must be either 1 or the same length ' ...
           'as the channel vector']);
  end

  ilength = length(initval);
  if( ilength == 1 && clength > 1 )
    oinitval = ones( 1, clength ) * initval;
  else
    oinitval = initval;
  end
  if( length( oinitval ) ~= clength )
    error(['Length of the initial value vector must be either 1 or the same ' ...
           'length as the channel vector']);
  end
end
