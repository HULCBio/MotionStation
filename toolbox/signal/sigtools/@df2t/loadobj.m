function Hd = loadobj(s)
%LOADOBJ Load filter for objects.
%   B = LOADOBJ(A) is called by LOAD when an object is loaded from a .MAT
%   file. The return value B is subsequently used by LOAD to populate the
%   workspace.  LOADOBJ can be used to convert one object type into
%   another, to update an object to match a new object definition, or to
%   restore an object that maintains information outside of the object
%   array.
%
%   If the input object does not match the current definition (as defined
%   by the constructor function), the input will be a struct-ized version
%   of the object in the .MAT file.  All the information in the original
%   object will be available for use in the conversion process.
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%
%   See also LOAD, SAVEOBJ.

%   Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:40:17 $ 
  
Hd = dfiltloadobj('df2t',s.dtf.dfilt.coefficients,s.dtf.dfilt.connection);
