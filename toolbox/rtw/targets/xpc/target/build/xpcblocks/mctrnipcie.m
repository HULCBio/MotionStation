function slot = mctrnipcie(phase, boardType, slot, channel)
% MCTRNIPCIE Mask initialization function for counters on E Series boards.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.3.6.1 $ $Date: 2004/03/02 03:04:08 $

  if phase == 1
    % input params: boardType, slot and channel not defined in phase 1.
    slot = evalin('caller', get_param( gcb, 'slot' ));
    channel = get_param( gcb, 'channel' );
    switch channel
     case 'Counter 0'
      chan = 1; % binary 01
     case 'Counter 1'
      chan = 2; % binary 10
     case 'Both'
      chan = 3; % binary 11
    end
    ctrmask = get_param( gcb, 'MaskType' );
    ctrblocks = find_system(bdroot, ...
                            'FollowLinks', 'on', ...
                            'LookUnderMasks', 'all',     ...
                            'MaskType', ctrmask );
    pwmmask = ['pwm',ctrmask(4:end)];
    pwmblocks = find_system(bdroot, ...
                           'FollowLinks', 'on', ...
                           'LookUnderMasks', 'all',     ...
                           'MaskType', pwmmask );
    
    count = 0;
    for i = 1 : length(ctrblocks)
      % because of a hardware register that is shared between the two
      % output channels, all output must be from the same blocks, but
      % there can be one output and one input on the same board from
      % different blocks, or two inputs from different blocks.
      block = ctrblocks{i};
      tmpslot = evalin('caller', get_param(block, 'slot') );
      if isequal( slot, tmpslot )
        count = count + 1;
      end
    end
    if count > 1  % catch split outputs first
      error('If you need two output channels on the same board, you need to use the same block for both');
    end
    for i = 1 : length(pwmblocks)
      block = pwmblocks{i};
      switch get_param( block, 'channel' )
       case '0'  % PWM uses simply '0' and '1', no both option.
        tmpchan = 1;
       case '1'
        tmpchan = 2;
      end
      tmpslot = evalin( 'caller', get_param(block, 'slot') );
      if isequal( slot, tmpslot ) && ( bitand(chan, tmpchan) ~= 0 )
        count = count + 1;
      end
    end
    if count > 1
      error('Illegal attempt to use the same counter channel for both input and output');
    end
  end

  if phase == 2
    bNames = {'PCI-6023E',     'PCI-6024E', 'PCI-6025E', 'PCI-6070E', ...
              'PCI-6040E',     'PXI-6070E', 'PXI-6040E', 'PCI-6071E', ...
              'PCI-6052E',     'PCI-6030E', 'PCI-6031E', 'PXI-6071E'};
    boardName = bNames{boardType};

    mdisp = ['disp(''' boardName '\nNational Instr.\nPulse Gen.'');'];
    if bitand(channel,1) %ctr 0 is used
      mdisp = [mdisp ...
               'port_label(''input'', 1, ''0'');' 10];
      if channel == 3
        mdisp = [mdisp ...
                 'port_label(''input'', 2, ''1'');' 10];
      end
    else
      mdisp = [mdisp ...
               'port_label(''input'', 1, ''1'');' 10];
    end
    set_param(gcb,'MaskDisplay',mdisp);

%    set_param(gcb, 'MaskDescription',                 ...
%                   [boardName,              char(10), ...
%                    'National Instruments', char(10), ...
%                    'Pulse Generation']);
  end
