function out = length(obj)
%LENGTH Length of serial port object array.
%
%   LENGTH(OBJ) returns the length of serial port object array,
%   OBJ. It is equivalent to MAX(SIZE(OBJ)).  
%    
%   See also SERIAL/SIZE.
%

%   MP 7-27-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:04:30 $


% The jobject property of the object indicates the number of 
% objects that are concatenated together.
try
   out = builtin('length', obj.jobject);
catch
   out = 1;
end




