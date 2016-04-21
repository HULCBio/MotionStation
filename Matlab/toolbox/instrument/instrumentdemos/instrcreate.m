function instrcreate
% INSTRCREATE Tool for creating and configuring instrument objects.
%
%    INSTRCREATE launches the Instrument Control Configuration Tool. 
%    Using this tool, new interface objects can be created, configured
%    and identified. Additionally, this tool lists all interface objects
%    that currently exist. The selected object can be configured and
%    identified. 
%    
%    The interface object can be saved to the MATLAB workspace, converted  
%    to the equivalent M-code, or saved to a MAT-file by selecting the 
%    Export button.
%
%    After the interface object is created, the object can be used from the
%    command line or it can be used in conjunction with the Test & Measurement
%    Tool, TMTOOL or with the Instrument Control Communication Tool, INSTRCOMM. 
% 
%    See also GPIB, SERIAL, TCPIP, UDP, VISA, TMTOOL, INSTRCOMM, 
%    INSTRUMENT/PROPINFO, INSTRHELP.
%

%    MP 05-17-02
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.16.4.7 $  $Date: 2004/01/16 20:03:32 $

import com.mathworks.toolbox.instrument.instrcreate.*;

% Determine if the window is hidden. If so, use it.
frame = InstrcreatePanel.getInstrcreatePanelFrame;
if ~isempty(frame)
    frame.show;
    return;
end

% Find the available hardware.
[serialPorts, gpibAdaptors, visaAdaptors, visaResourceNames] = instrgate('privateFindHwInfo');

% Create the instrcreate panel.
panel = InstrcreatePanel;
panel.setAvailableHardware(serialPorts, gpibAdaptors, visaAdaptors, visaResourceNames);

% Show the instrcreate panel.
panel.addToFrame;

