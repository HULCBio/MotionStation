function val = isa(hndl,type)
%SCRIBEHANDLE/ISA Test isa for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:13:09 $

if strcmpi(class(hndl), type)
   val = 1;
else
   val = builtin('isa',hndl,type);
end
