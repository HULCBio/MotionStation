function hObj = h5string(varargin)
%H5STRING  Constructor for hdf5.h5string object.
%
%   HDF5STRING = hdf5.h5string('temperature');

%   Copyright 1984-2002 The MathWorks, Inc.

if (nargin >= 1)
    if (nargin == 2)
        hObj = hdf5.h5string;
        hObj.setData(varargin{1});
        hObj.setPadding(varargin{2});
    elseif (nargin == 1)
        hObj = hdf5.h5string;
        hObj.setData(varargin{1});
        hObj.setPadding('nullterm');
    else
        error('MATLAB:h5string:h5string:tooManyInputs', ...
              'Too many input arguments to constructor.')
    end
    
elseif (nargin == 0)
    hObj = hdf5.h5string;
    hObj.setLength(0);
    hObj.setPadding('nullterm');
end
    
