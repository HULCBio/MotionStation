%SAVEOBJ Save filter for objects.
%   B = SAVEOBJ(A) is called by SAVE when an object is saved to a .MAT
%   file. The return value B is subsequently used by SAVE to populate the
%   .MAT file.  SAVEOBJ can be used to convert an object that maintains 
%   information outside the object array into saveable form (so that a
%   subsequent LOADOBJ call to recreate it).
%
%   SAVEOBJ will be separately invoked for each object to be saved.
%
%   SAVEOBJ can be overloaded only for user objects.  SAVE will not call
%   SAVEOBJ for a built-in datatype (such as double) even if @double/saveobj
%   exists.
%
%   See also SAVE, LOADOBJ.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 03:21:30 $
