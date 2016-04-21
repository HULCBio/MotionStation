function [maskdisplay, base] = mencsensoray526( phase, channel, baseaddress )

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/30 13:13:46 $
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');

    masktype = get_param( gcb, 'MaskType' );
    baseaddr = get_param( gcb, 'baseaddress' );
    chan = get_param( gcb, 'channel' );
    encblocks = find_system( bdroot, ...
                             'FollowLinks',    'on', ...
                             'LookUnderMasks', 'all', ...
                             'MaskType',       masktype, ...
                             'baseaddress',    baseaddr, ...
                             'channel',        chan );
    
    % Now count -pwm and -mpwm blocks as well, can't share hardware!
    idx = findstr( masktype, '-' );
    pwmtype = [masktype( 1:idx ), 'pwm' ];    % pwm output blocks
    pwmblocks = find_system( bdroot, ...
                             'FollowLinks',    'on', ...
                             'LookUnderMasks', 'all', ...
                             'MaskType',       pwmtype, ...
                             'baseaddress',    baseaddr, ...
                             'channel',        chan );

    mpwmtype = [masktype( 1:idx ), 'mpwm' ];  % measure pwm blocks
    mpwmblocks = find_system(bdroot, ...
                                 'FollowLinks',    'on', ...
                                 'LookUnderMasks', 'all', ...
                                 'MaskType',       mpwmtype, ...
                                 'baseaddress',    baseaddr, ...
                                 'channel',        chan );
    if length(encblocks) + length(mpwmblocks) + length(pwmblocks) > 1
      error('Only one Sensoray 526 block allowed in a model for each timer channel on any single board address.');
    end
    
  end
  
  if phase == 2  % called as mask init function for analog input
    %disp('Called as mask init function');
    maskdisplay = 'disp(''526\nSensoray\nEncoder Input '');';
    
    
    outport = [' port_label(''output'', 1,''', num2str(channel),''');'];
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
  end  % end phase 2 code
