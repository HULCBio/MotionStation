function out = length(obj)
%LENGTH Length of data acquisition object.
%
%    LENGTH(OBJ) returns the length of data acquisition object, OBJ.  
%    It is equivalent to MAX(SIZE(OBJ)).  OBJ can be a device object 
%    or a channel/line.
%    
%    See also DAQHELP, DAQCHILD/SIZE.
%

%    MP 4-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:27 $

% The handle property of the object indicates the number of 
% objects that are concatenated together.
if any(strcmp(class(obj), {'aochannel', 'aichannel', 'dioline'}))
   h = struct(obj);
   out = builtin('length', h.handle);
else
   out = 1;
end