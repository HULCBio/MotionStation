function connect(varargin)
%CONNECT Connect device object to instrument.
%
%   CONNECT(OBJ) connects the device object, OBJ, to the instrument. OBJ
%   can be an array of device objects.
%
%   If OBJ was successfully connected to the instrument, OBJ's Status property 
%   is configured to open, otherwise the Status property remains configured to
%   closed. 
%
%   If OBJ is an array of device objects and one of the objects cannot be 
%   connected to the instrument, the remaining objects in the array will 
%   be connected to the instrument and a warning will be displayed.
%
%   CONNECT(OBJ, 'UPDATE') connects the device object, OBJ, to the instrument. 
%   UPDATE can be either 'object' or 'instrument'. If UPDATE is 'object', then
%   the object is updated to reflect the state of the instrument. If UPDATE 
%   is 'instrument' then the instrument is updated to reflect the state of 
%   the object, i.e. all property values defined by the object are sent to 
%   the instrument on open. By default, Update is 'object'.
%
%   Example:
%       % Construct a device object that has specific information about a 
%       % Tektronix TDS 210 instrument.
%       g = gpib('ni', 0, 2);
%       d = icdevice('tektronix_tds210', g);      
%
%       % Connect to the instrument
%       connect(d);
%
%       % List the oscilloscope settings that can be configured.
%       props = set(d);
%
%       % Get the current configuration of the oscilloscope.
%       values = get(d);
%
%       % Disconnect from the instrument and cleanup.
%       disconnect(d);
%       delete([d g]);
%
%   See also ICDEVICE/DISCONNECT, INSTRUMENT/DELETE, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:42 $

error('icgroup:connect:unsupportedFcn', 'Wrong object type passed to CONNECT. Use the object''s parent.');
