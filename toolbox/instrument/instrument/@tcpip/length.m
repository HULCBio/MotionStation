function out = length(obj)
%LENGTH Length of instrument object array.
%
%   LENGTH(OBJ) returns the length of instrument object array,
%   OBJ. It is equivalent to MAX(SIZE(OBJ)).  
%    
%   See also TCPIP/SIZE, INSTRHELP.
%

%   MP 7-27-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.3 $  $Date: 2004/01/16 20:01:49 $


% The jobject property of the object indicates the number of 
% objects that are concatenated together.
try
   out = builtin('length', obj.jobject);
catch
   out = 1;
end




