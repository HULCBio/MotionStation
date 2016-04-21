function setData(hObj, data)
%SETDATA  Set the hdf5.h5string's data.
%
%   HDF5STRING = hdf5.h5string;
%   HDF5STRING.setData('East Coast');

%   Copyright 1984-2002 The MathWorks, Inc.

thisLength = numel(data);
maxLength = hObj.Length;

if (thisLength ~= length(data))
    error('MATLAB:h5string:setData:badRank', ...
          'Strings must be 1-D.')
end

if (maxLength == 0)
    hObj.setLength(thisLength);
elseif (thisLength > maxLength)
    warning('MATLAB:h5string:setData:stringTruncation', ...
            'String will be truncated when written.')
end

hObj.Data = data;
