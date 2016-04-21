function setLength(hObj, len)
%SETLENGTH  Set length of the hdf5.h5string datatype.
%
%   HDF5STRING = hdf5.h5string('East Coast');
%   HDF5STRING.setLength(20);

%   Copyright 1984-2002 The MathWorks, Inc.

hObj.Length = len;
