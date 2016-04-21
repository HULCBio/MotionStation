function mquamask( when, nchans )

% when selects how this function is called.
% when == 1 when called from mask initialization
% when == 2 when called from a change in any value in the mask
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.6.1 $ $Date: 2003/09/02 01:15:24 $

%disp(['mquamask: when = ', num2str(when)]);

if when == 1
  
%disp('mask init');

  params = get_param( gcb, 'MaskValues' );
  set_param( [gcb,'/IRQ Source'], 'irqNo', params{3} );
  set_param( [gcb,'/Int Check'], 'irqnum', params{3} );

  % params:
  %    1 == group
  %    2 == port
  %    3 == irqnum
  %    4 == slot
  %
  %    5 == baud
  %    6 == parity
  %    7 == ndata
  %    8 == nstop
  %    9 == fifomode
  %   10 == rlevel
  %   11 == automode
  %   12 == xmtfifosize
  %   13 == xmtdatatype
  %   14 == rcvfifosize
  %   15 == rcvmaxread
  %   16 == rcvminread
  %   17 == rcvusedelim
  %   18 == rcvdelim
  %   19 == rcvdatatype
  %   20 == rcvsampletime
  %
  %   21 start over with baud
  
  for port = 1:nchans
    s = 5 + (port - 1) * 16;
    set_param( [ gcb,'/Setup', num2str(port) ], 'baud', params{s} );
    set_param( [ gcb,'/Setup', num2str(port) ], 'parity', params{s + 1} );
    set_param( [ gcb,'/Setup', num2str(port) ], 'width', num2str(params{s + 2}) );
    set_param( [ gcb,'/Setup', num2str(port) ], 'nstop', num2str(params{s + 3}) );
    set_param( [ gcb,'/Setup', num2str(port) ], 'fmode', params{s + 4} );
    set_param( [ gcb,'/Setup', num2str(port) ], 'rlevel', params{s + 5} );
    set_param( [ gcb,'/Setup', num2str(port) ], 'ctsmode', params{s + 6} );

    set_param( [ gcb,'/FIFO write ', num2str(port) ], 'size', params{s + 7} );
    set_param( [ gcb,'/FIFO write ', num2str(port) ], 'inputtype', params{s + 8} );
    % Prepare the transmit fifo overflow message id.
    irq = get_param( [gcb,'/IRQ Source'], 'irqNo' );
    tmpid = ['XMT channel ', num2str(port), ', IRQ ', num2str(irq)];
    set_param( [ gcb,'/FIFO write ', num2str(port) ], 'id', tmpid );
    
    set_param( [ gcb,'/RS232 ISR/While Iterator Subsystem/FIFO write ', num2str(port) ], 'size', params{s + 9} );
    % Prepare the receive fifo overflow message id.
    tmpid = ['RCV channel ', num2str(port), ', IRQ ', num2str(irq)];
    set_param( [ gcb,'/RS232 ISR/While Iterator Subsystem/FIFO write ', num2str(port) ], 'id', tmpid );
    
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'maxsize', params{s + 10} );
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'minsize', params{s + 11} );
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'usedelimiter', params{s + 12} );
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'delimiter', params{s + 13} );
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'outputtype', params{s + 14} );
    set_param( [ gcb,'/FIFO read ', num2str(port) ], 'sampletime', params{s + 15} );
  end
end

if when == 2
%disp('group changed');
  displaystr = 'on';
  group = get_param( gcb, 'group' );
  groupok = false;
  if strcmp( group, 'Board Setup' )
    groupok = true;
    displaystr = [displaystr,',off,on,on'];
    for pt = 1:nchans
      displaystr = [displaystr,',off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,off'];
    end
  else

    displaystr = [displaystr,',on,off,off'];

    port = str2num(get_param( gcb, 'port' ));
    if port > 1
      for pt = 1:port-1
        displaystr = [displaystr,',off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,off'];
      end
    end
    
    if strcmp( group, 'Basic Setup' )
      groupok = true;
      displaystr = [displaystr,',on,on,on,on,on,on,on,off,off,off,off,off,off,off,off,off'];
    end
    if strcmp( group, 'Transmit Setup' )
      groupok = true;
      displaystr = [displaystr,',off,off,off,off,off,off,off,on,on,off,off,off,off,off,off,off'];
    end
    if strcmp( group, 'Receive Setup' )
      groupok = true;
      displaystr = [displaystr,',off,off,off,off,off,off,off,off,off,on,on,on,on,on,on,on'];
    end
    if groupok == false
      disp( 'Illegal parameter group' );
    end
  
    if port < nchans
      for pt = port+1:nchans
        displaystr = [displaystr,',off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,off'];
      end
    end
  end
  
  set_param( gcb, 'MaskVisibilityString', displaystr );
  
end

if when == 3
  % InitFcn for cross block checking. PCI serial boards
  
  masktype = get_param( gcb, 'MaskType' );
  slot = get_param( gcb, 'slot' );
  sameserial = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype, 'slot', slot );
  if length(sameserial) > 1
    error('This block uses the same board as another block.  This won''t work correctly.');
  end
  
  irq = get_param( gcb, 'irqnum' );
  % Look at all the xpcinterrupt blocks so we catch other uses of this
  % IRQ than just the serial blocks.
  sameirq = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'xpcinterrupt', 'irqNo', irq );
  
  if length( sameirq ) > 1
    error( 'This subsystem uses the same IRQ as another subsystem.  This won''t work correctly.' );
  end
end

%disp('exit mquamask');