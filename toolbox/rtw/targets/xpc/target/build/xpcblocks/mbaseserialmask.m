function [addr1, addr2, maskdisplay] = mbaseserialmask( when, nchans )

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.6.1 $ $Date: 2003/09/02 01:15:16 $

% when selects how this function is called.
% when == 1 when called from mask initialization
% when == 2 when called from a change in any value in the mask

if when == 1
  
%disp('mask init');

  params = get_param( gcb, 'MaskValues' );

  % params:
  %    1 == group
  %    2 == port
  %    3 == irqnum
  %    4 == first port address (custom)
  %    5 == second port address (custom)
  %    6 == config
  %
  %    7 == baud
  %    8 == parity
  %    9 == ndata
  %   10 == nstop
  %   11 == fifomode
  %   12 == rlevel
  %   13 == automode
  %   14 == xmtfifosize
  %   15 == xmtdatatype
  %   16 == rcvfifosize
  %   17 == rcvmaxread
  %   18 == rcvminread
  %   19 == rcvusedelim
  %   20 == rcvdelim
  %   21 == rcvdatatype
  %   22 == rcvsampletime
  %
  %   23 start over with baud
  
  % Return default base addresses for first and second boards.
  config = params(6);
  maskdisplay = 'disp(''Baseboard\nRS232\nSend Receive'')';
  if strcmp('Com1/none', config)
    inport1 = 'port_label(''input'',1,''XMT1'');';
    inport2 = 'port_label(''input'',2,'''');';
    outport1 = 'port_label(''output'',1,''RCV1'');';
    outport2 = 'port_label(''output'',2,'''');';
    addr1 = '0x3f8';
    addr2 = '0x0';
    irq = '4';
  end
  if strcmp('Com2/none', config)
    inport1 = 'port_label(''input'',1,''XMT2'');';
    inport2 = 'port_label(''input'',2,'''');';
    outport1 = 'port_label(''output'',1,''RCV2'');';
    outport2 = 'port_label(''output'',2,'''');';
    addr1 = '0x2f8';
    addr2 = '0x0';
    irq = '3';
  end
  if strcmp('Com1/Com3', config)
    inport1 = 'port_label(''input'',1,''XMT1'');';
    inport2 = 'port_label(''input'',2,''XMT3'');';
    outport1 = 'port_label(''output'',1,''RCV1'');';
    outport2 = 'port_label(''output'',2,''RCV3'');';
    addr1 = '0x3f8';
    addr2 = '0x3e8';
    irq = '4';
  end
  if strcmp('Com2/Com4', config)
    inport1 = 'port_label(''input'',1,''XMT2'');';
    inport2 = 'port_label(''input'',2,''XMT4'');';
    outport1 = 'port_label(''output'',1,''RCV2'');';
    outport2 = 'port_label(''output'',2,''RCV4'');';
    addr1 = '0x2f8';
    addr2 = '0x2e8';
    irq = '3';
  end
  if strcmp('none/Com3', config)
    inport1 = 'port_label(''input'',1,'''');';
    inport2 = 'port_label(''input'',2,''XMT3'');';
    outport1 = 'port_label(''output'',1,'''');';
    outport2 = 'port_label(''output'',2,''RCV3'');';
    addr1 = '0x0';
    addr2 = '0x3e8';
    irq = '4';
  end
  if strcmp('none/Com4', config)
    inport1 = 'port_label(''input'',1,'''');';
    inport2 = 'port_label(''input'',2,''XMT4'');';
    outport1 = 'port_label(''output'',1,'''');';
    outport2 = 'port_label(''output'',2,''RCV4'');';
    addr1 = '0x0';
    addr2 = '0x2e8';
    irq = '3';
  end
  if strcmp('Custom', config)
    irq = params{3};      % get irqnum
    addr1 = params{4};    % get saddr1
    if isempty(addr1(3:end))
      addr1 = '0x0';
    end
    addr2 = params{5};    % get saddr2
    if isempty(addr2(3:end))
      addr2 = '0x0';
    end
    inport1 = ['port_label(''input'',1,''XMT ',addr1(3:end),''');'];
    inport2 = ['port_label(''input'',2,''XMT ',addr2(3:end),''');'];
    outport1 = 'port_label(''output'',1,''RCV'');';
    outport2 = 'port_label(''output'',2,''RCV'');';
  end
  set_param( [gcb,'/IRQ Source'], 'irqNo', irq );
  maskdisplay = [maskdisplay,inport1,inport2,outport1,outport2];
%  disp('end when==1');
end

if when == 3
%  disp('start when==3');
  params = get_param( gcb, 'MaskValues' );
  for port = 1:nchans
    tmpid = '';
    s = 7 + (port - 1) * 16;
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
  config = get_param( gcb, 'config' );
  groupok = false;
  if strcmp( group, 'Board Setup' )
    groupok = true;
    displaystr = [displaystr,',off'];  % Port to modify:
    if strcmp('Custom', config)
      displaystr = [displaystr,',on,on,on,on']; % irq, adr1, adr2, config
    else
      displaystr = [displaystr,',off,off,off,on']; % irq, adr1, adr2, config
    end
    for pt = 1:nchans
      displaystr = [displaystr,',off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,off'];
    end
  else

    displaystr = [displaystr,',on,off,off,off,off'];

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
% InitFcn for cross block checking. Baseboard type boards
%  disp('InitFcn');
  
  masktype = get_param( gcb, 'MaskType' );
  params = get_param( gcb, 'MaskValues' );

  % Find base addresses this block
  config = params(6);
  [addra, addrb, irq] = getaddr( config, params );
  
  samemask = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype );
  nsameaddr = 0;  % count the number of blocks using the same addr1, addr2 or irq
  nsameirq = 0;
  for cnt = 1:length(samemask)
    nparams = get_param( samemask{cnt}, 'MaskValues' );
    [naddr1, naddr2, nirq] = getaddr( nparams{6}, nparams );
    if (strcmp( addra, naddr1) & ~strcmp( addra, '0x0' )) | (strcmp( addrb, naddr2) & ~strcmp( addrb, '0x0' ))
      nsameaddr = nsameaddr + 1;
    end
    if strcmp( irq, nirq)
      nsameirq = nsameirq + 1;
    end
  end
  
  if nsameaddr ~= 1
    error( 'This block shares a UART address with another serial IO block.  This won''t work.' );
  end
  
  if nsameirq ~= 1
    error( 'This block shares an irq with another serial IO block.  This won''t work.' );
  end
end

function [addr1, addr2, irq] = getaddr( config, params )
if strcmp('Com1/none', config)
    addr1 = '0x3f8';
    addr2 = '0x0';
    irq = '4';
  end
  if strcmp('Com2/none', config)
    addr1 = '0x2f8';
    addr2 = '0x0';
    irq = '3';
  end
  if strcmp('Com1/Com3', config)
    addr1 = '0x3f8';
    addr2 = '0x3e8';
    irq = '4';
  end
  if strcmp('Com2/Com4', config)
    addr1 = '0x2f8';
    addr2 = '0x2e8';
    irq = '3';
  end
  if strcmp('none/Com3', config)
    addr1 = '0x0';
    addr2 = '0x3e8';
    irq = '4';
  end
  if strcmp('none/Com4', config)
    addr1 = '0x0';
    addr2 = '0x2e8';
    irq = '3';
  end
  if strcmp('Custom', config)
    irq = params{3};      % get irqnum
    addr1 = params{4};    % get saddr1
    if isempty(addr1(3:end))
      addr1 = '0x0';
    end
    addr2 = params{5};    % get saddr2
    if isempty(addr2(3:end))
      addr2 = '0x0';
    end
  end
