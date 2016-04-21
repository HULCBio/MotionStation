function [baseAddressOut, maskdisplay, maskdescription] = ...
    mdiodiamondquartz(phase, type, channel, baseAddress)

% MDIODIAMONDQUARTZ - Mask Initialization for Diamond QUARTZ-MM DIO section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.5.4.1 $ $Date: 2004/03/02 03:04:46 $

  if phase == 1
    % collect information from all blocks having the same MaskType
    masktype = get_param( gcb, 'MaskType' );
    blocks=find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', masktype );
    % if only one instance is found skip next step
    if length(blocks)>1
      % loop over all blocks and collect all information for cross-block checking
      %maskValues= get_param(blocks,'MaskValues');
      info.baseAddress= zeros(1,length(blocks));
      for block=1:length(blocks)
        % Base Address (physical board reference)
        addr = get_param( blocks(block), 'baseAddressIn' );
        info.baseAddress(block)= convertAddress(addr{1});
      end
      % do cross-block checking by using the collected information
      % check for multiple instances using the same physical board
      if length(info.baseAddress)~=length(unique(info.baseAddress))
        error('only one instance per physical board allowed');
      end
    end
  end

  if phase == 2
    % check parameters
    % channel
    if isempty(channel)
      error('Channel Vector parameter cannot be empty');
    end
    if ~isa(channel,'double')
      error('Channel Vector parameter must be of class double');
    end
    if size(channel,1)>1
      error('Channel Vector parameter must be a row vector');
    end
    % round channel vector
    channel= round(channel);
    % check for channel elements smaller than 1 or greater than 8
    if ~isempty(find(channel<1)) | ~isempty(find(channel>8))
      error('Channel Vector elements must be in the range 1..8');
    end
    % check for channelsalready used
    tmp=zeros(1,8);
    for i=channel
      if tmp(i)
        error(['Channel ',num2str(i),' already in use']);
      end
      tmp(i) = 1;
    end

    % check Base Address
    baseAddressOut = convertAddress(baseAddress);

    % construct Mask icon
    vendorName = 'Diamond';
    switch type 
     case 1
      deviceName ='Quartz-MM-10';
      description = 'Digital Output';
      portdirection = 'input';
     case 2
      deviceName ='Quartz-MM-10';
      description = 'Digital Input';
      portdirection = 'output';
     case 3
      deviceName ='Quartz-MM-5';
      description = 'Digital Output';
      portdirection = 'input';
     case 4
      deviceName ='Quartz-MM-5';
      description = 'Digital Input';
      portdirection = 'output';
    end

    maskdisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    for i = 1:length(channel)
      maskdisplay = sprintf('%s port_label(''%s'', %i, ''%i'');', maskdisplay, portdirection, i, channel(i));
    end         

    maskdescription = [deviceName 10 vendorName 10 description];
  end
  
function addrnum = convertAddress(addrstr)

  if length(addrstr)<2
    error('Base Addresses must begin with 0x denoting hexadecimal values');
  end
  if addrstr(1)~='0' | addrstr(2)~='x'
    error('Base Addresses must begin with 0x denoting hexadecimal values');
  end
  addrnum=hex2dec(addrstr(3:end));
  if isempty(addrnum)
    error('Invalid Base Address specified');
  end


