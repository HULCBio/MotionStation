function instrcomm(varargin)
%INSTRCOMM Tool for communication with instrument.
%
%    INSTRCOMM launches the Instrument Control Communication Tool.
%    The Instrument Control Communication Tool is a graphical tool
%    for communicating with an instrument. The Instrument Control
%    Communication Tool:      
%
%         - displays the interface objects that have been created
%         - provides a tool to create new interface objects
%         - provides a tool to configure interfacce object properties
%         - connects or disconnects the interface object from the instrument
%         - reads or writes Binary or ASCII data from the instrument 
%         - exports data read from the instrument to the MATLAB workspace, 
%           MAT-file, MATLAB figure window or MATLAB array editor
%         - converts the communication with the instrument to an M-File
%
%    INSTRCOMM(OBJ) opens the Instrument Control Communication Tool with 
%    interface object, OBJ, selected.
%
%    See also GPIB, SERIAL, TCPIP, UDP, VISA, TMTOOL, INSTRCREATE, 
%    INSTRUMENT/PROPINFO, INSTRHELP.
%

%    MP 01-22-00
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.13.4.6 $  $Date: 2004/01/16 20:03:31 $

import com.mathworks.toolbox.instrument.instrcomm.*;

% Error checking.
if nargin > 1
    error('instrumentdemos:instrcomm:tooManyInput', 'Too many input arguments.');
end

% Verify OBJ type if specified.
switch nargin
case 1
    % Error checking.
    if ~isa(varargin{1}, 'icinterface')
        error('instrumentdemos:instrcomm:invalidArg', 'OBJ must be an instrument object.');
    end
    
    if ~isvalid(varargin{1})
        error('instrumentdemos:instrcomm:invalidArg', 'Instrument object OBJ is an invalid object.');
    end

    if (length(varargin{1}) > 1)
        error('instrumentdemos:instrcomm:invalidArg', 'OBJ must be a 1-by-1 instrument object.');
    end
end

% Determine if the window is hidden. If so, use it.
frame = InstrcommPanel.getInstrcommPanelFrame;
if ~isempty(frame)
    frame.show;
    return;
end

% Find the available hardware.
[serialPorts, gpibAdaptors, visaAdaptors, visaResourceNames] = instrgate('privateFindHwInfo');

% Create the instrcromm panel.
panel = InstrcommPanel;
panel.setAvailableHardware(serialPorts, gpibAdaptors, visaAdaptors, visaResourceNames);

% Configure instrcomm to select OBJ.
if (nargin == 1)
    panel.setCurrentObject(java(igetfield(varargin{1}, 'jobject')));
end

% Show the instrcomm panel.
panel.addToFrame;

