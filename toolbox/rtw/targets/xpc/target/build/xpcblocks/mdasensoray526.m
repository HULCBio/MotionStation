function [maskdisplay, base1, reset1, initial1, base2, reset2, initial2] = ...
    mdualdasensoray526( phase, channels1, reset1, initial1, baseaddress1, ...
                        channels2, reset2, initial2, baseaddress2 )

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/30 13:13:43 $
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');

    masktype = get_param( gcb, 'MaskType' );
    baseaddr1 = get_param( gcb, 'baseaddress1' );
    baseaddr2 = get_param( gcb, 'baseaddress2' );

    lb1 = 0;
    if ~strcmp( baseaddr1, '0' )
      myblocks11 = find_system(bdroot, ...
                               'FollowLinks', 'on', ...
                               'LookUnderMasks', 'all', ...
                               'MaskType', masktype, ...
                               'baseaddress1', baseaddr1);
      myblocks21 = find_system(bdroot, ...
                               'FollowLinks', 'on', ...
                               'LookUnderMasks', 'all', ...
                               'MaskType', masktype, ...
                               'baseaddress2', baseaddr1);
      lb1 = length(myblocks11) + length(myblocks21);
    end
    lb2 = 0;
    if ~strcmp( baseaddr2, '0' )
      myblocks12 = find_system(bdroot, ...
                               'FollowLinks', 'on', ...
                               'LookUnderMasks', 'all', ...
                               'MaskType', masktype, ...
                               'baseaddress1', baseaddr2);
      myblocks22 = find_system(bdroot, ...
                               'FollowLinks', 'on', ...
                               'LookUnderMasks', 'all', ...
                               'MaskType', masktype, ...
                               'baseaddress2', baseaddr2);
      lb2 = length(myblocks12) + length(myblocks22);
    end
    
    if (lb1 > 1) || ( lb2 > 1 )
      error('Only one Sensoray 526 analog input block allowed in a model for any single board address.');
    end
  end

  if phase == 2  % called as mask init function for analog input
    %disp('Called as mask init function');
    maskdisplay = 'disp(''526\nSensoray\nAnalog Output'');';
    
    inport = '';
    if ~strcmp( baseaddress1, '0' )
      nchan1 = length(channels1);
      if nchan1 ~= length(unique(channels1))
        error('You can''t use the same channel more than once.');
      end
    else
      nchan1 = 0;
    end
    if ~strcmp( baseaddress2, '0' )
      nchan2 = length(channels2);
      if nchan2 ~= length(unique(channels2))
        error('You can''t use the same channel more than once.');
      end
    else
      nchan2 = 0;
    end
    
    if nchan1 > 4 || nchan2 > 4
      error('This board can have from 1 to 4 output channels.');
    end
      
    if ~strcmp( baseaddress1, '0' )
      for i = 1:nchan1
        if (channels1(i) < 1) || (channels1(i) > 4)
          error('Channel numbers for the D/A must be in the range [1,4]');
        end
        if ~strcmp( baseaddress2, '0' )
          s = sprintf(' port_label(''input'', %d, ''A-%d'');', i, channels1(i));
        else
          s = sprintf(' port_label(''input'', %d, ''%d'');', i, channels1(i));
        end
        inport = [inport, s];
        % inport = [inport, ' port_label(''input'',',num2str(i),',''', num2str(channels(i)),''');'];
      end
    end
    if ~strcmp( baseaddress2, '0' )
      for i = 1:nchan2
        if (channels2(i) < 1) || (channels2(i) > 4)
          error('Channel numbers for the D/A must be in the range [1,4]');
        end
        if ~strcmp( baseaddress1, '0' )
          s = sprintf(' port_label(''input'', %d, ''B-%d'');', i+nchan1, channels2(i));
        else
          s = sprintf(' port_label(''input'', %d, ''%d'');', i, channels2(i));
        end
        inport = [inport, s];
        % inport = [inport, ' port_label(''input'',',num2str(i),',''', num2str(channels(i)),''');'];
      end
    end
    maskdisplay = [maskdisplay, inport ];

    minaddr = 512;   % 0x200
    maxaddr = 65472; % 0xffc0
    addrinc = 64;    % 0x40
    base1 = 0;
    base2 = 0;
    if ~strcmp( baseaddress1, '0' )
      base1 = hex2dec(baseaddress1(3:end));
      if base1 < minaddr
        error('Use a base address above 0x200');
      end
      if base1 > maxaddr
        error('Use a base address below 0xFFC0');
      end
      if mod( base1, addrinc ) ~= 0
        error('The base address must be a multiple of 0x40');
      end
    end
    if ~strcmp( baseaddress2, '0' )
      base2 = hex2dec(baseaddress2(3:end));
      if base2 < minaddr
        error('Use a base address above 0x200');
      end
      if base2 > maxaddr
        error('Use a base address below 0xFFC0');
      end
      if mod( base2, addrinc ) ~= 0
        error('The base address must be a multiple of 0x40');
      end
    end
    
    % check the reset and initial vectors.
    if ~strcmp( baseaddress1, '0' )
      if length(reset1) ~= nchan1
        if length(reset1) == 1
          reset1 = reset1 * ones(1, nchan1);
        else
          error('The reset vector must have the same length as the channel vector, or length 1');
        end
      end
      if length(initial1) ~= nchan1
        if length(initial1) == 1
          initial1 = initial1 * ones(1, nchan1);
        else
          error('The initial value vector must have the same length as the channel vector, or length 1');
        end
      end
    end
    if ~strcmp( baseaddress2, '0' )
      if length(reset2) ~= nchan2
        if length(reset2) == 1
          reset2 = reset2 * ones(1, nchan2);
        else
          error('The reset vector must have the same length as the channel vector, or length 1');
        end
      end
      if length(initial2) ~= nchan2
        if length(initial2) == 1
          initial2 = initial2 * ones(1, nchan2);
        else
          error('The initial value vector must have the same length as the channel vector, or length 1');
        end
      end
    end
  end  % end phase 2 code
