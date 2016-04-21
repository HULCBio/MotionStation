function obj = icinterface(validname)
%ICINTERFACE Construct icinterface object.
%
%   ICINTERFACE constructs the parent class for interface objects. Interface
%   objects include: serial port, GPIB, VISA, TCPIP and UDP objects. 
%
%   An interface object is instantiated with the SERIAL, GPIB, VISA, TCPIP and
%   UDP constructors. This constructor should not be called directly by users.
%
%   See also GPIB, SERIAL, TCPIP, UDP, VISA.
%

%   MP 9-03-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:37 $

% Create the parent class.
try
    instr = instrument(validname);
catch
    error('instrument:icinterface:nojvm', 'Instrument objects require JAVA support.');
end

obj.store = {};
obj = class(obj, 'icinterface', instr);
