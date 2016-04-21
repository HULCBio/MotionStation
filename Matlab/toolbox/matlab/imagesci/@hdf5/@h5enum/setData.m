function setData(hObj, data)
%SETDATA  Set the data for the hdf5.h5enum object
%
%   HDF5ENUM = hdf5.h5enum({'ALPHA' 'RED' 'GREEN' 'BLUE'}, ...
%              uint8([0 1 2 3]));
%   HDF5ENUM.setData(uint8([3 0 1 2]));

%   Copyright 1984-2002 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end


if ((isempty(hObj.enumNames)) || (isempty(hObj.enumValues)))
    error('MATLAB:h5enum:setData:missingEnumData', ...
          'Enumeration data is unset.');
end

if (~isequal(class(hObj.enumValues), class(data)))
    error('MATLAB:h5enum:setData:differentType', ...
          'Enumeration data must have the same type as definition.')
elseif ((isa(data, 'single')) || (isa(data, 'double')))
    error('MATLAB:h5enum:setData:wrongType', ...
          'Data must be an integer type.')
end

if (~isempty(setdiff(data, hObj.enumValues)))
    warning('MATLAB:h5enum:setData:invalidValue', ...
            'Some values in data are not valid enumerated values.')
end

hObj.Data = data;
