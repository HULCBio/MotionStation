function setPadding(hObj, padding)
%SETPADDING  Set padding of hdf5.h5string datatype.
%
%   HDF5STRING = hdf5.h5string('East Coast');
%   HDF5STRING.setLength(20);
%   HDF5STRING.setPadding('spacepad');

%   Copyright 1984-2002 The MathWorks, Inc.

list = {'spacepad', 'nullterm', 'nullpad'};
index = strmatch(lower(padding), list);
if ~index
    error('MATLAB:h5string:setPadding:paddingValue', ...
          'PADDING must be ''spacepad'', ''nullterm'', or ''nullpad''');
end

hObj.Padding = list{index};
