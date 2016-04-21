function defineEnum(hObj, stringValues, numberValues)
%DEFINEENUM  Add the enum definition to the hdf5.h5enum object.
%
%   HDF5ENUM = hdf5.h5enum;
%   HDF5ENUM.defineEnum({'RED','BLUE','GREEN','BLACK'}, ...
%                       uint8([1 2 3 0]);

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:36 $
%   Copyright 1984-2002 The MathWorks, Inc.

% Parse inputs.
if (~iscellstr(stringValues))
    error('MATLAB:h5enum:defineEnum:badStringValueType', ...
          'First argument must be cellstr.');
    
elseif (numel(stringValues) ~= numel(numberValues))
    error('MATLAB:h5enum:defineEnum:unbalancedValues', ...
          'You must provide an equal number of strings and values.')
    
end

% Put the data.
hObj.setEnumNames(stringValues);
hObj.setEnumValues(numberValues);
