function out = length(obj)
%LENGTH Length of instrument object array.
%
%   LENGTH(OBJ) returns the length of instrument object array, OBJ. 
%   It is equivalent to MAX(SIZE(OBJ)).  
%    
%   See also ICDEVICE/SIZE, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:17 $


% The jobject property of the object indicates the number of 
% objects that are concatenated together.
try
   out = builtin('length', obj.jobject);
catch
   out = 1;
end




