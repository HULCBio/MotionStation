function out = length(obj)
%LENGTH Length of data acquisition object.
%
%    LENGTH(OBJ) returns the length of data acquisition object, OBJ.  
%    It is equivalent to MAX(SIZE(OBJ)).  OBJ can be a device object 
%    array or a channel/line.
%    
%    See also DAQHELP, DAQCHILD/SIZE.
%

%    MP 4-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:41:20 $

% The handle property of the object indicates the number of 
% objects that are concatenated together.
try
   h = struct(obj);
   out = builtin('length', h.handle);
catch
   out = 1;
end

