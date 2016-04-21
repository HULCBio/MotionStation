function [maskdisplay] = mfiforw( boolport, boolout, direction)

% mfiforw -- prepare maskdisplay so the port labels are correct

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2003/04/24 18:18:06 $

if direction == 1  % write to the fifo
  maskdisplay= 'disp( ''FIFO\nwrite'');port_label(''input'',1,''D'');';
  maskdisplay = [maskdisplay, 'port_label(''output'', 1, ''F'');'];
  if boolport == 1
    maskdisplay = [maskdisplay, 'port_label(''output'', 2, ''DP'');'];
  end
else  % read from the fifo
  maskdisplay= 'disp( ''FIFO\nRead'');port_label(''output'',1,''D'');';
  maskdisplay=[maskdisplay,'port_label(''input'',1,''F'');'];
  if boolport == 1
    maskdisplay=[maskdisplay,'port_label(''input'',2,''MAX'');'];
    maskdisplay=[maskdisplay,'port_label(''input'',3,''MIN'');'];
  end 
  if boolout == 1
    maskdisplay=[maskdisplay,'port_label(''output'',2,''ENA'');'];
  end 
end
