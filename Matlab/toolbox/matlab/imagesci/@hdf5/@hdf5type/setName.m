function setName(hObj, name)
%SETNAME  Set the hdf5.hdf5type object's name.
%
%   HDF5STRING = hdf5.h5string('East Coast');
%   HDF5STRING.setLength(20);
%   HDF5STRING.setName('shared datatype #1');

%   Copyright 1984-2002 The MathWorks, Inc.

hObj.Name = name;
