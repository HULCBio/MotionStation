function obj = icinterface(validname)
%ICINTERFACE Construct icinterface object.
%
%   ICINTERFACE constructs the parent class for interface objects. 
%   Interface objects include: serial port, GPIB, VISA, TCPIP and 
%   UDP objects. 
%
%   Note, the GPIB, VISA, TCPIP and UDP objects are included with the
%   Instrument Control Toolbox.
%
%   An interface object is instantiated with the SERIAL, GPIB, VISA,
%   TCPIP and UDP constructors. This constructor should not be called
%   directly by users.
%
%   See also SERIAL.
%

%   MP 9-03-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:03:53 $

% Create the parent class.
try
    instr = instrument(validname);
catch
    error('MATLAB:icinterface:icinterface:nojvm', 'Instrument objects require JAVA support.');
end

obj.store = {};
obj = class(obj, 'icinterface', instr);
