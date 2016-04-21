function cellstr = getString(hObj)
%GETSTRING   Returns the hdf5.h5enum data as the enumeration's
%   keys (strings.)
%
%   HDF5ENUM = hdf5.h5enum({'ALPHA' 'RED' 'GREEN' 'BLUE'}, ...
%              uint8([0 1 2 3]));
%   HDF5ENUM.setData(uint8([3 0 1 2]));
%   HDF5ENUM.getString

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:37 $
%   Copyright 1984-2002 The MathWorks, Inc.

origSize = size(hObj.Data);
cellstr = cell(origSize);

for i = 1:numel(hObj.Data)

    % This looks up a data value to find the corresponding string
    % key in the HDF5 enumeration.    
    cellstr{i} = hObj.EnumNames{find(hObj.Data(i) == hObj.EnumValues)};
end

% Sanity check that cellstr is indeed a cellstr
if (~iscellstr(cellstr))
    error('MATLAB:h5enum:getString:badEnumData', ...
          'Bad enumeration data to key look-up');
end

