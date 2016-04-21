function [maskdisplay, base, diocsr] = mdisensoray526( phase, channels, baseaddress )

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/30 13:13:44 $
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');
    dimasktype = get_param( gcb, 'MaskType' );
    baseaddr = get_param( gcb, 'baseaddress' );
    mydinblocks = find_system(bdroot,'FollowLinks', 'on', ...
                              'LookUnderMasks', 'all', ...
                              'MaskType', dimasktype, ...
                              'baseaddress', baseaddr);
    if length(mydinblocks) > 1
      error('Only one Sensoray 526 digital input block allowed in a model for any single board address.');
    end
    index = findstr( dimasktype, '-' );
    domasktype = [dimasktype(1:index),'dout'];
    mydoblocks = find_system(bdroot,'FollowLinks', 'on', ...
                             'LookUnderMasks', 'all', ...
                             'MaskType', domasktype, ...
                             'baseaddress', baseaddr);

    % Check the first one for channel overlap.  Multiples will be caught
    % by the init function for the do block.
    dinchannels = get_param( gcb, 'channel' );
    dinchannels = str2num( dinchannels );
    digrp = zeros(1,2);
    dogrp = zeros(1,2);
    for ind = 1:length(dinchannels)
      if dinchannels(ind) < 5
        digrp(1,1) = 1;
      else
        digrp(1,2) = 1;
      end
    end

    if length( mydoblocks ) > 0
      dochannels = get_param( mydoblocks{1}, 'channel' );
      dochannels = str2num( dochannels );
      for ind = 1:length(dochannels)
        if dochannels(ind) < 5
          dogrp(1,1) = 1;
        else
          dogrp(1,2) = 1;
        end
      end
      if (digrp(1,1) == 1 && dogrp(1,1) == 1) || (digrp(1,2) == 1 && dogrp(1,2) == 1)
        error('Channels in each group of 4 must be either input or output, not both');
      end
    end
    % need dogrp to decide how to program the DIO control register.
    set_param( gcb, 'UserData', dogrp );
  end
  
  if phase == 2  % called as mask init function for analog input
    %disp('Called as mask init function');
    maskdisplay = 'disp(''526\nSensoray\nDigital Input'');';
    dogrp = get_param( gcb, 'UserData' );
    if length(dogrp) == 0  % can happen on model open.
      dogrp = zeros(1,2);
    end
    
    outport = '';
    nchan = length(channels);
    if nchan > 8
      error('This board can have from 1 to 8 input channels.');
    end
    if nchan ~= length(unique(channels))
      error('You can''t use the same channel more than once.');
    end
    for ind = 1:nchan
      if (channels(ind) > 8) || (channels(ind) < 1)
        error('Channel numbers for digital IO must be in the range [1,8]');
      end
      outport = [outport, ' port_label(''output'',',num2str(ind),',''', num2str(channels(ind)),''');'];
    end
    maskdisplay = [maskdisplay, outport ];

    base = hex2dec(baseaddress(3:end));
    minaddr = 512;   % 0x200
    maxaddr = 65472; % 0xffc0
    addrinc = 64;    % 0x40
    if base < minaddr
      error('Use a base address above 0x200');
    end
    if base > maxaddr
      error('Use a base address below 0xFFC0');
    end
    if mod( base, addrinc ) ~= 0
      error('The base address must be a multiple of 0x40');
    end
    
    diocsr = 0;
    if dogrp(1,1) == 1
      diocsr = diocsr + 1024;  % bit 10, 0x400
    end
    if dogrp(1,2) == 1
      diocsr = diocsr + 2048;  % bit 11, 0x800
    end
    % sprintf('mdi: diocsr = 0x%x\n', diocsr )
   
  end  % end phase 2 code
