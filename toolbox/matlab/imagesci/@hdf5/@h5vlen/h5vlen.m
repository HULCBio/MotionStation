function hObj = h5vlen(varargin)
%H5VLEN  Constructor for an hdf5.h5vlen object.
%
%   HDF5STRING = hdf5.h5vlen({0 [0 1] [0 2] [0:10]});

%   Copyright 1984-2002 The MathWorks, Inc.

if (nargin == 1)
    hObj = hdf5.h5vlen;
    hObj.setData(varargin{1});
elseif (nargin == 0)
    hObj = hdf5.h5vlen;
else
    error('MATLAB:h5vlen:h5vlen:tooManyInputs', ...
          'Too many arguments to constructor.')
end
