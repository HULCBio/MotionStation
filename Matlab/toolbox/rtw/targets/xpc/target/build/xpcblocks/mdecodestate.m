function [maskdisplay, count] = mdecodestate( overrun, parity, frame, breakint )

% mdecodestate -- Count the number of state variables to output from the
% block and prepare maskdisplay.
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2003/01/22 20:19:08 $

  
  count = 1;
  maskdisplay = 'disp(''RS232\nState'');port_label(''input'',1,''D'');port_label(''output'',1,''D'');';
  if overrun == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''O'');' ];
  end
  if parity == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''P'');' ];
  end
  if frame == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''F'');' ];
  end
  if breakint == 1
    count = count + 1;
    maskdisplay = [ maskdisplay, 'port_label(''output'',',num2str(count),',''B'');' ];
  end
%maskdisplay
