function result=isa(arg1, arg2)
%ISA Overload of the ISA() for data acquisition objects.
%

%    DK 09-25-01   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.2.2.4 $  $Date: 2003/08/29 04:41:15 $

% Convert class specifier to lowercase for comparison]
if ~ischar(arg2)
	error('daq:isa:command', 'Unknown command option.');
end

% Check to see if one of supported DAQ classes is specified
if any(strcmp(arg2, {'analoginput', 'analogoutput', 'digitalio', 'daqdevice'}));
	result = any(strcmp({class(arg1), 'daqdevice'}, arg2));
else
	result = 0;
end
	
