function [maskdisplay, count, addr] = mmodemstatus( when, cts, dsr, ring, dcd, type, config, addr )

% mmodemstatus -- Count the number of state variables to output from the
% block and prepare maskdisplay.
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.2.6.1 $ $Date: 2003/09/02 01:15:21 $

  
  if when == 1  % when config changes in the baseboard driver mask parameters
    config = get_param( gcb, 'config' );
    if strcmp('Custom', config)
      displaystr = 'on,on,on,on,on,on,on';
    else
      displaystr = 'on,on,on,on,on,on,off';
    end
    set_param( gcb, 'MaskVisibilityString', displaystr );
  end
 
  if when == 2  % normal mask init call
    count = 0;
    switch type
     case 1
      maskdisplay = 'disp(''QSC-100\nQuatech\nModem Status'');';
     case 2
      maskdisplay = 'disp(''ESC-100\nQuatech\nModem Status'');';
     case 3
      maskdisplay = 'disp(''QSC-200/300\nQuatech\nModem Status'');';
     case 4
      maskdisplay = 'disp(''Baseboard\nModem Status'');';
     case 5
      maskdisplay = 'disp(''Diamond\nEmerald-MM\nModem Status'');';
     case 6
      maskdisplay = 'disp(''Diamond\nEmerald-MM-8\nModem Status'');';
    end
  
    if cts == 1
      count = count + 1;
      maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''CTS'');' ];
    end
    if dsr == 1
      count = count + 1;
      maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''DSR'');' ];
    end
    if ring == 1
      count = count + 1;
      maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''RI'');' ];
    end
    if dcd == 1
      count = count + 1;
      maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''DCD'');' ];
    end
    if type == 4   % baseboard UART, need to get address
    
      switch config
       case( 'Com1' )
        addr = '0x3f8';
       case( 'Com2' )
        addr = '0x2f8';
       case( 'Com3' )
        addr = '0x3e8';
       case( 'Com4' )
        addr = '0x2e8';
       case( 'Custom' )
%        disp('Using given address');
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
    if type == 6  % Diamond Emerald-MM
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
%maskdisplay
  end
