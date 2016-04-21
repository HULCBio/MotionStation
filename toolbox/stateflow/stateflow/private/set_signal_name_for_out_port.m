function set_signal_name_for_out_port(portH)

%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.3.2.1 $

portName = get_param(portH,'name');
portHandles = get_param(portH,'PortHandles');
lineH = get_param(portHandles.Inport,'line');
if(ishandle(lineH))
    set_param(lineH,'name',portName);
end