function result=isa(arg1, arg2)
%ISA True if object is a given class.
%
%   ISA(OBJ,'class_name') returns 1 if OBJ is of the class, or inherits
%   from the class, 'class_name' and 0 otherwise.
%

%   MP 09-26-01   
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 19:59:15 $

% Error checking.
if ~ischar(arg2)
	error('icdevice:isa:badopt', 'Unknown command option.');
end

if strcmp(arg2, 'instrument')
    result = true;
elseif strcmp(arg2, class(arg1))
    result = true;
else
    result = false;
end  
