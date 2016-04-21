function addr = mdiamondemeraldmask( when, nchans )

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/02 01:15:18 $

% when selects how this function is called.
% when == 1 when called from mask initialization
% when == 2 when called from a change in any value in the mask

% disp(['mdiamondemeraldmask: when = ',num2str(when)]);

if when == 1
  
%disp('mask init');

  params = get_param( gcb, 'MaskValues' );

  % params:
  %    1 == group
  %    2 == port
  %    3 == irqnum
  %    4 == first port address (custom)
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
  
  % Return addresses for the 4 or 8 UARTs and for the interrupt status register.
  addr = get_addr( params{4}, nchans );
  irq = params{ 3 };
  set_param( [gcb,'/IRQ Source'], 'irqNo', irq );
%  disp('end when==1');
end

if when == 3
%  disp('start when==3');
  params = get_param( gcb, 'MaskValues' );
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
%  disp('exit mbaseserialmask');
end

if when == 2
%disp('group changed');
  displaystr = 'on';  % Parameter group:
  group = get_param( gcb, 'group' );
  groupok = false;
  if strcmp( group, 'Board Setup' )
    groupok = true;
    displaystr = [displaystr,',off'];  % Port to modify:
    displaystr = [displaystr,',on,on']; % irq, adr1
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

if when == 4
% InitFcn for cross block checking.  Diamond Emerald type boards
%  disp('InitFcn');
  masktype = get_param( gcb, 'MaskType' );
  params = get_param( gcb, 'MaskValues' );

  % Find base addresses this block
  irq =  params(3);
  address = params{4};
  firstaddr = get_addr( address, nchans );
  
  samemask = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype );
  nsameaddr = 0;  % count the number of blocks using the same addr1 or irq
  nsameirq = 0;
  for cnt = 1:length(samemask)
    nparams = get_param( samemask{cnt}, 'MaskValues' );
    nirq = nparams{3};
    secondaddr = get_addr(nparams{4}, nchans );
    
    % When we compare against the same block, we increment nsameaddr,
    % then when we compare with another board, we only increment if any
    % of the 5 addresses of one board are the same as any of the 5 on
    % the other board.  This is needed since the 2 base addresses, 0x3f8
    % and 0x3e8, yield overlapping addresses.  Also, base 0x380 and
    % base 0x240 share an interrupt status register address.  We have
    % to catch these.
    alladdr = {firstaddr{1:nchans+1}, secondaddr{1:nchans+1}};
    lall = length( alladdr );
    uniq = unique( alladdr );
    luniq = length( uniq );

    if lall ~= luniq
      nsameaddr = nsameaddr + 1;
    end
    
    if strcmp( irq, nirq )
      nsameirq = nsameirq + 1;
    end
  end
  
  if nsameaddr ~= 1
    error( ['This block shares an address with another Diamond Emerald ' ...
            'serial IO block.  This won''t work.'] );
  end
  
  if nsameirq ~= 1
    error( 'This block shares an irq with another serial IO block.  This won''t work.' );
  end
end

% disp('mdiamondemeraldmask: exit');  switch addr1

function addr = get_addr( addr1, nchans )
  if nchans == 4
    switch addr1
     case ( '0x3F8' )
      addr = { '0x3f8', '0x2f8', '0x3e8', '0x2e8', '0x220' };
     case ( '0x3E8' )
      addr = { '0x3e8', '0x2e8', '0x3a8', '0x2a8', '0x220' };
     case ( '0x380' )
      addr = { '0x380', '0x388', '0x288', '0x230', '0x224' };
     case ( '0x240' )
      addr = { '0x240', '0x248', '0x260', '0x268', '0x224' };
     case ( '0x100' )
      addr = { '0x100', '0x108', '0x110', '0x118', '0x240' };
     case ( '0x120' )
      addr = { '0x120', '0x128', '0x130', '0x138', '0x244' };
     case ( '0x140' )
      addr = { '0x140', '0x148', '0x150', '0x158', '0x248' };
     case ( '0x160' )
      addr = { '0x160', '0x168', '0x170', '0x178', '0x24c' };
    end
  else % nchans == 8
    switch addr1
     case ( '0x100' )
      addr = { '0x100', '0x108', '0x110', '0x118', '0x120', '0x128', '0x130', ...
               '0x138', '0x140', '0x102' };
     case ( '0x140' )
      addr = { '0x140', '0x148', '0x150', '0x158', '0x160', '0x168', '0x170', ...
               '0x178', '0x180', '0x142' };
     case ( '0x180' )
      addr = { '0x180', '0x188', '0x190', '0x198', '0x1a0', '0x1a8', '0x1b0', ...
               '0x1b8', '0x1c0', '0x182' };
     case ( '0x1c0' )
      addr = { '0x1c0', '0x1c8', '0x1d0', '0x1d8', '0x1e0', '0x1e8', '0x1f0', ...
               '0x1f8', '0x200', '0x1c2' };
     case ( '0x200' )
      addr = { '0x200', '0x208', '0x210', '0x218', '0x220', '0x228', '0x230', ...
               '0x238', '0x240', '0x202' };
     case ( '0x240' )
      addr = { '0x240', '0x248', '0x250', '0x258', '0x260', '0x268', '0x270', ...
               '0x278', '0x280', '0x242' };
     case ( '0x280' )
      addr = { '0x280', '0x288', '0x290', '0x298', '0x2a0', '0x2a8', '0x2b0', ...
               '0x2b8', '0x2c0', '0x282' };
     case ( '0x2c0' )
      addr = { '0x2c0', '0x2c8', '0x2d0', '0x2d8', '0x2e0', '0x2e8', '0x2f0', ...
               '0x2f8', '0x300', '0x2c2' };
     case ( '0x300' )
      addr = { '0x300', '0x308', '0x310', '0x318', '0x320', '0x328', '0x330', ...
               '0x338', '0x340', '0x302' };
     case ( '0x340' )
      addr = { '0x340', '0x348', '0x350', '0x358', '0x360', '0x368', '0x370', ...
               '0x378', '0x380', '0x342' };
     case ( '0x380' )
      addr = { '0x380', '0x388', '0x390', '0x398', '0x3a0', '0x3a8', '0x3b0', ...
               '0x3b8', '0x3c0', '0x382' };
     case ( '0x3c0' )
      addr = { '0x3c0', '0x3c8', '0x3d0', '0x3d8', '0x3e0', '0x3e8', '0x3f0', ...
               '0x3f8', '0x3b8', '0x3c2' };
    end
  end
