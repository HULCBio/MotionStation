function ptr=libstruct(structtype,initialvalue)
%LIBSTRUCT Creates a structure pointer for use with external libraries.
%
%   M = LIBSTRUCT('STRUCTTYPE') returns an empty libstruct of the given type
%   type can be any structure defined in a loaded library.
%
%   M = LIBSTRUCT('STRUCTTYPE',INITIALVALUE) returns a libstruct object
%   initialized to the INITIALVALUE supplied.
%
%   See also LIBPOINTER, JAVA.
   
%   Copyright 2002-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/03/17 20:05:23 $
if nargin==1
    ptr=feval(['lib.' structtype]);
else
    ptr=feval(['lib.' structtype],initialvalue);
end
