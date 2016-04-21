function obj = instrument(validname)
%INSTRUMENT Construct instrument object.
%
%   INSTRUMENT is the base class from which interface and device objects
%   are derived from. Interface objects are serial port, TCPIP, UDP,
%   GPIB, VISA objects. Note, the GPIB, VISA, TCPIP, UDP and device objects 
%   are included with the Instrument Control Toolbox.
% 
%   See also SERIAL.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/01/16 20:03:50 $

% Determine if called directly or from constructor.
if (nargin == 0 || ~any(strcmp(validname, {'serial', 'gpib', 'visa', 'tcpip', 'udp', 'icdevice'})))
    % The instrument constructor was called directly.
    if isempty(which('gpib'))
    	error('MATLAB:instrument:instrument:invalidSyntax', 'An instrument object is instantiated through the SERIAL constructor.');    
    else
    	error('MATLAB:instrument:instrument:invalidSyntax', 'An instrument object is instantiated through the SERIAL, GPIB, VISA, TCPIP, UDP or ICDEVICE constructor.')
    end
end

% Error if java is not running.
if ~usejava('jvm')
    error('MATLAB:instrument:instrument:nojvm', 'The instrument object requires JAVA support.');
end

obj.store = {};
obj = class(obj, 'instrument');