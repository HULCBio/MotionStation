function setEnumNames(hObj, stringValues)
%SETENUMNAMES  Set the hdf5.h5enum's string values.
%
%   HDF5ENUM.setEnumNames({'ALPHA' 'RED' 'GREEN' 'BLUE'});

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:40 $
%   Copyright 1984-2002 The MathWorks, Inc.

if (~iscellstr(stringValues))
    error('MATLAB:h5enum:setEnumNames:nameValueType', ...
          'Name values must be strings.');
    
elseif (numel(stringValues) ~= length(stringValues))
    error('MATLAB:h5enum:setEnumNames:nameValueRank', ...
          'Name values must be vectors.');
    
end

hObj.EnumNames = stringValues;
