function [maskdisplay,base,gain] = malaim16( phase, first_channel, last_channel, coupling, gain, baseaddress )
% When called by digital input or output, the meaning of the parameters
% is different.  
% first_channel => channel vector
% last_channel => channel group
% coupling => direction
% gain == 0
% baseaddress is the same.


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/08 21:02:44 $
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');

    masktype = get_param( gcb, 'MaskType' );
    baseaddr = get_param( gcb, 'baseaddress' );
    idx = findstr( masktype, '-' );
    aintype = [masktype( 1:idx ), 'ain' ];
    myainblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',aintype,'baseaddress', baseaddr);
    if length(myainblocks) > 1
      error('Only one Analogic AIM16 or AIM12 input block allowed in a model for any single board address.');
    end
    altaintype = aintype;
    if aintype( idx-1 ) == '2'
      altaintype( idx-1 ) = '6';
    end
    if aintype( idx-1 ) == '6'
      altaintype( idx-1 ) = '2';
    end
    altainblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',altaintype,'baseaddress', baseaddr);
    if length(altainblocks) + length(myainblocks) > 1
      error('Only one Analogic AIM16 or AIM12 input block allowed in a model for any single board address.');
    end
    
    % If this is a DIN or DOUT board, check for others.
    type = masktype( idx+1:end );
    if strcmp( type,'din') | strcmp( type, 'dout' )
      dintype = [masktype( 1:idx ),'din'];
      altdintype = dintype;
      if dintype( idx - 1 ) == '2'
        altdintype( idx - 1 ) = '6';
      end
      if dintype( idx - 1 ) == '6'
        altdintype( idx - 1 ) = '2';
      end
      channelgroup = get_param( gcb, 'channelgroup' );
      dinblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',dintype,'baseaddress', baseaddr, 'channelgroup', channelgroup );
      altdinblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',altdintype,'baseaddress', baseaddr, 'channelgroup', channelgroup );
      douttype = [masktype( 1:idx ),'dout'];
      altdouttype = douttype;
      if douttype( idx - 1 ) == '2'
        altdouttype( idx - 1 ) = '6';
      end
      if douttype( idx - 1 ) == '6'
        altdouttype( idx - 1 ) = '2';
      end
      doutblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',douttype,'baseaddress', baseaddr, 'channelgroup', channelgroup );
      altdoutblocks = find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',altdouttype,'baseaddress', baseaddr, 'channelgroup', channelgroup );
      if length( dinblocks ) + length( altdinblocks ) + length( doutblocks ) + length( altdoutblocks ) > 1
        error('There can be only one digital input or output per group on the AIM16 or AIM12 for each board.');
      end
    end
  end
  
  if phase == 2  % called as mask init function for analog input
    %disp('Called as mask init function');
    masktype = get_param( gcb, 'MaskType' );
    idx = findstr( masktype, '-' );
    bdtype = masktype( idx - 1 );
    if bdtype == '6'
      maskdisplay = 'disp(''AIM16\nAnalogic\nAnalog Input'');';
    end
    if bdtype == '2'
      maskdisplay = 'disp(''AIM12\nAnalogic\nAnalog Input'');';
    end
    
    switch coupling
     case 1  % single ended
      maxchan = 16;
      cpl = 'single ended';
     case 2  % differential
      maxchan = 8;
      cpl = 'differential';
    end
    
    if first_channel < 1 | first_channel > maxchan
      error(['In ',cpl,' mode, the first input channel must be in the range 1..', num2str(maxchan)]);
    end
    if last_channel < first_channel
      error('The last channel must be greater than or equal to the first channel');
    end
    if last_channel > maxchan
      error(['In ', cpl,' mode, the last input channel must be in the range 1..', num2str(maxchan)]);
    end
    
    outport = '';
    for i = first_channel:last_channel
      outport = [outport, ' port_label(''output'',',num2str(i+1-first_channel),',''', num2str(i),''');'];
    end
    maskdisplay = [maskdisplay, outport ];

    base = hex2dec(baseaddress(3:end));
    minaddr = 512;   % 0x200
    maxaddr = 992;   % 0x3e0
    addrinc = 32;    % 0x20
    if base < minaddr
      error('Use a base address above 0x200');
    end
    if base > maxaddr
      error('Use a base address below 0x3e0');
    end
    if mod( base, addrinc ) ~= 0
      error('The base address must be a multiple of 0x20');
    end
    
    nchans = last_channel - first_channel + 1;
    if length(gain) == 1 & nchans > 1
      gain = gain * ones( 1, nchans );
    end
    % Check length again to make sure.
    lth = length(gain);
    if length(gain) ~= nchans
      error('The gain vector must have either 1 element or the same number of elements as there are channels.');
    end
    if bdtype == '2'
      for i = 1:lth
        g = gain(i);
        if g ~= 1 & g ~= 10 & g ~= 100
          error('Legal gain values for the AIM12 are 1, 10 and 100.');
        end
      end
    end
    if bdtype == '6'
      for i = 1:lth
        g = gain(i);
        if g ~= 1 & g ~= 2 & g ~= 4 & g ~= 8
          error('Legal gain values for the AIM16 are 1, 2, 4 and 8.');
        end
      end
    end
    
  end  % end phase 2 code

  if phase == 3  % mask init function for digital input or output
% first_channel => channel vector
% last_channel => channel group
% coupling => direction
% gain == 0
% baseaddress is the same.
    %disp('Called as mask init function');
    masktype = get_param( gcb, 'MaskType' );
    idx = findstr( masktype, '-' );
    bdtype = masktype( idx - 1 );
    if bdtype == '6'
      maskdisplay = 'disp(''AIM16\nAnalogic\n';
    end
    if bdtype == '2'
      maskdisplay = 'disp(''AIM12\nAnalogic\n';
    end
    
    channel = first_channel;
    channelgroup = last_channel;
    direction = coupling;
    
    base = hex2dec(baseaddress(3:end));
    minaddr = 512;   % 0x200
    maxaddr = 992;   % 0x3e0
    addrinc = 32;    % 0x20
    if base < minaddr
      error('Use a base address above 0x200');
    end
    if base > maxaddr
      error('Use a base address below 0x3e0');
    end
    if mod( base, addrinc ) ~= 0
      error('The base address must be a multiple of 0x20');
    end
    
    switch direction
     case 1
      maskdisplay = [maskdisplay,'Digital Input'');'];
      outport = '';
      for i = 1:length(channel)
        outport = [outport,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
      end
      maskdisplay = [maskdisplay,outport];
     case 2
      maskdisplay = [maskdisplay,'Digital Output'');'];
      inport = '';
      for i = 1:length(channel)
        inport = [inport,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
      end
      maskdisplay = [maskdisplay,inport];
    end
    
  end
