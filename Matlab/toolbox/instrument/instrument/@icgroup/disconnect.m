function disconnect(obj)
%DISCONNECT Disconnect device object from instrument.
%
%   DISCONNECT(OBJ) disconnects device object, OBJ, from the instrument.
%
%   If OBJ was successfully disconnected from the instrument, OBJ's Status
%   property is configured to closed. OBJ can be reconnected to the instrument
%   with the CONNECT function.
%
%   If OBJ is an array of device objects and one of the objects cannot be 
%   disconnected from the instrument, the remaining objects in the array will 
%   be disconnected from the instrument and a warning will be displayed.
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
%   See also ICDEVICE/CONNECT, INSTRUMENT/DELETE, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:44 $

error('icgroup:disconnect:unsupportedFcn', 'Wrong object type passed to DISCONNECT. Use the object''s parent.');
