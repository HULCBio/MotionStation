function slot = mctrnipciecap(phase, bType, slot, channel)
% MCTRNIPCICAP Capture block mask initialization for NI E series boards

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.3.6.1 $ $Date: 2004/03/02 03:04:09 $

  if phase == 1
    % input params: bType, slot and channel not defined in phase 1.
    slot = evalin('caller', get_param( gcb, 'slot' ));
    channel = get_param( gcb, 'channel' );
    switch channel
     case '0'
      chan = 1; % binary 01
     case '1'
      chan = 2; % binary 10
    end
    pwmtype = get_param(gcb, 'MaskType');
    pwmblocks = find_system(bdroot,  ...
                            'FollowLinks', 'on', ...
                            'LookUnderMasks', 'all',     ...
                            'MaskType', pwmtype );
    ctrtype = ['ctr',pwmtype(4:end)];
    ctrblocks = find_system(bdroot, ...
                            'FollowLinks', 'on', ...
                            'LookUnderMasks', 'all',     ...
                            'MaskType', ctrtype );

    count = 0;
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
      error('Only one block instance allowed per counter channel');
    end

    for i = 1 : length(ctrblocks)
      block = ctrblocks{i};
      switch get_param( block, 'channel' )
       case 'Counter 0'
        tmpchan = 1;
       case 'Counter 1'
        tmpchan = 2;
       case 'Both'
        tmpchan = 3;
      end
      tmpslot = evalin('caller', get_param(block, 'slot') );
      if isequal( slot, tmpslot ) && ( bitand(chan, tmpchan) ~= 0 )
        count = count + 1;
      end
    end
    if count > 1
      error('Illegal attempt to use the same counter channel for both input and output');
    end
  end
  
  if phase == 2  % MaskInit call
    bNames = {'PCI-6023E', 'PCI-6024E', 'PCI-6025E', 'PCI-6070E', ...
              'PCI-6040E', 'PXI-6070E', 'PXI-6040E', 'PCI-6071E', ...
              'PCI-6052E', 'PCI-6030E', 'PCI-6031E', 'PXI-6071E'};

    boardName = bNames{bType};
    mdisp = ['disp(''' boardName '\nNational Instr.\nPulsewidth/Period Meas.'');'];
    if channel == 0  %ctr 0 is used
      mdisp = [mdisp ...
               'port_label(''output'', 1, ''0'');' 10];
    else % channel == 1
      mdisp = [mdisp ...
               'port_label(''output'', 1, ''1'');' 10];
    end
    set_param(gcb,'MaskDisplay',mdisp);
  end
