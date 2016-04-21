function [maskdisplay, count, addr] = mmodemcontrol( when, rts, dtr, type, config, addr )

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.3.6.1 $ $Date: 2003/09/02 01:15:20 $
%  disp(['mmodemcontrol: when = ',num2str(when)]);
if when == 1  % when config changes in the baseboard driver
  config = get_param( gcb, 'config' );
  if strcmp('Custom', config)
    displaystr = 'on,on,on,on';
  else
    displaystr = 'on,on,on,off';
  end
  set_param( gcb, 'MaskVisibilityString', displaystr );
end

% mmodemcontrol -- prepare maskdisplay.
if when == 2
  count = 0;
  switch type
   case 1
    maskdisplay = 'disp(''QSC-100\nQuatech\nModem Control'');';
   case 2
    maskdisplay = 'disp(''ESC-100\nQuatech\nModem Control'');';
   case 3
    maskdisplay = 'disp(''QSC-200/300\nQuatech\nModem Control'');';
   case 4
    maskdisplay = 'disp(''Baseboard\nModem Control'');';
   case 5
    maskdisplay = 'disp(''Diamond\nEmerald-MM\nModem Control'');';
   case 6
    maskdisplay = 'disp(''Diamond\nEmerald-MM-8\nModem Control'');';
  end
  
  if rts == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''input'',',num2str(count),',''RTS'');' ];
  end
  if dtr == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''input'',',num2str(count),',''DTR'');' ];
  end

  if type == 4   % baseboard UART, need to get address
    
    if strcmp('Com1', config)
      addr = '0x3f8';
    end
    if strcmp('Com2', config)
      addr = '0x2f8';
    end
    if strcmp('Com3', config)
      addr = '0x3e8';
    end
    if strcmp('Com4', config)
      addr = '0x2e8';
    end
    if strcmp('Custom', config)
      %disp('Using given address');
    end
  end
  if type == 5   % Diamond Emerald-MM
                 % config is the port
                 % input addr is the address of the first port on the board.
    port = config;
    inaddr = lower(addr);
    addrtmp = { '0x0', '0x0', '0x0', '0x0' };

    switch inaddr
     case ( '0x3f8' )
      addrtmp = { '0x3f8', '0x2f8', '0x3e8', '0x2e8' };
     case ( '0x3e8' )
      addrtmp = { '0x3e8', '0x2e8', '0x3a8', '0x2a8' };
     case ( '0x380' )
      addrtmp = { '0x380', '0x388', '0x288', '0x230' };
     case ( '0x240' )
      addrtmp = { '0x240', '0x248', '0x260', '0x268' };
     case ( '0x100' )
      addrtmp = { '0x100', '0x108', '0x110', '0x118' };
     case ( '0x120' )
      addrtmp = { '0x120', '0x128', '0x130', '0x138' };
     case ( '0x140' )
      addrtmp = { '0x140', '0x148', '0x150', '0x158' };
     case ( '0x160' )
      addrtmp = { '0x160', '0x168', '0x170', '0x178' };
    end
    addr = addrtmp{port};
      
  end
  if type == 6   % Diamond Emerald-MM8
                 % config is the port
                 % input addr is the address of the base register on the board.
    port = config;
    inaddr = lower(addr);
    addrtmp = { '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0'};

    switch inaddr
     case ( '0x100' )
      addrtmp = { '0x108', '0x110', '0x118', '0x120', ...
                  '0x128', '0x130', '0x138', '0x140' };
     case ( '0x140' )
      addrtmp = { '0x148', '0x150', '0x158', '0x160', ...
                  '0x168', '0x170', '0x178', '0x180' };
     case ( '0x180' )
      addrtmp = { '0x188', '0x190', '0x198', '0x1a0', ...
                  '0x1a8', '0x1b0', '0x1b8', '0x1c0' };
     case ( '0x1c0' )
      addrtmp = { '0x1c8', '0x1d0', '0x1d8', '0x1e0', ...
                  '0x1e8', '0x1f0', '0x1f8', '0x200' };
     case ( '0x200' )
      addrtmp = { '0x208', '0x210', '0x218', '0x220', ...
                  '0x228', '0x230', '0x238', '0x240' };
     case ( '0x240' )
      addrtmp = { '0x248', '0x250', '0x258', '0x260', ...
                  '0x268', '0x270', '0x278', '0x280' };
     case ( '0x280' )
      addrtmp = { '0x288', '0x290', '0x298', '0x2a0', ...
                  '0x2a8', '0x2b0', '0x2b8', '0x2c0' };
     case ( '0x2c0' )
      addrtmp = { '0x2c8', '0x2d0', '0x2d8', '0x2e0', ...
                  '0x2e8', '0x2f0', '0x2f8', '0x300' };
     case ( '0x300' )
      addrtmp = { '0x308', '0x310', '0x318', '0x320', ...
                  '0x328', '0x330', '0x338', '0x340' };
     case ( '0x340' )
      addrtmp = { '0x348', '0x350', '0x358', '0x360', ...
                  '0x368', '0x370', '0x378', '0x380' };
     case ( '0x380' )
      addrtmp = { '0x388', '0x390', '0x398', '0x3a0', ...
                  '0x3a8', '0x3b0', '0x3b8', '0x3c0' };
     case ( '0x3c0' )
      addrtmp = { '0x3c8', '0x3d0', '0x3d8', '0x3e0', ...
                  '0x3e8', '0x3f0', '0x3f8', '0x3b8' };
    end
    addr = addrtmp{port};
      
  end
end

% As an InitFcn to check for other blocks using the same board.
% when == 3 for PCI boards
if when == 3
  % An error if the same slot and port appear in more than 1 block with this
  % masktype.
  masktype = get_param( gcb, 'MaskType' );
  slot = get_param( gcb, 'slot' );
  port = get_param( gcb, 'port' );
  sameport = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype, 'slot', slot, 'port', port );
  if length(sameport) > 1
    error('Using ModemControl to the same port on the same board from multiple blocks will cause glitches in the output.  Not allowed.');
  end
end

% when == 4 for ISA or baseboard UARTS
if when == 4
  masktype = get_param( gcb, 'MaskType' );
  params = get_param( gcb, 'MaskValues' );
  baddr = getaddr( params );
  sameblock = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype );
  nsameaddr = 0;
  for cnt = 1:length(sameblock)
    newparams = get_param( sameblock{cnt}, 'MaskValues' );
    naddr = getaddr( newparams );
    if strcmp( baddr, naddr )
      nsameaddr = nsameaddr + 1;
    end
  end
  if nsameaddr > 1
    error('Using ModemControl to the same UART from multiple blocks will cause glitches in the output.  Not allowed.');
  end
end
  
% when == 5 for the diamond Emerald-MM board
if when == 5
%  disp('Emerald-mm initfcn');
  masktype = get_param( gcb, 'MaskType' );
  params = get_param( gcb, 'MaskValues' );
  port = params(3);
  addr = lower(params(4));
  
  sameblock = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', masktype );
  nsameaddr = 0;
  for cnt = 1:length(sameblock)
    newparams = get_param( sameblock{cnt}, 'MaskValues' );
    nport = newparams(3);
    naddr = lower(newparams(4));
    if strcmp( addr, naddr ) && strcmp( port, nport )
      nsameaddr = nsameaddr + 1;
    end
  end
  if nsameaddr > 1
    error('Using ModemControl to the same UART from multiple blocks will cause glitches in the output.  Not allowed.');
  end
end
% disp('leave mmodemcontrol');

function addr = getaddr( params )
  config = params{3};
  if strcmp('Com1', config)
    addr = '0x3f8';
  end
  if strcmp('Com2', config)
    addr = '0x2f8';
  end
  if strcmp('Com3', config)
    addr = '0x3e8';
  end
  if strcmp('Com4', config)
    addr = '0x2e8';
  end
  if strcmp('Custom', config)
    addr = params{4};    % get saddr1
    if isempty(addr(3:end))
      addr = '0x0';
    end
  end
