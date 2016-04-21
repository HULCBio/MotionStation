function q = saveobj(q)
%SAVEOBJ Save filter for objects.
%   B = SAVEOBJ(A) is called by SAVE when an object is saved to a .MAT
%   file. The return value B is subsequently used by SAVE to populate the
%   .MAT file.  SAVEOBJ can be used to convert an object that maintains 
%   informaton outside the object array into saveable form (so that a
%   subsequent LOADOBJ call to recreate it).
%
%   SAVEOBJ will be separately invoked for each object to be saved.
%
%   See also SAVE, LOADOBJ.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:35:56 $

% Rely on the saveobj of the parent class.
q.quantizer = saveobj(q.quantizer);

