function hObj = h5array(varargin)
%H5ARRAY  Constructor for hdf5.h5array objects
%
%   hdf5array = hdf5.h5array;
%
%   hdf5array = hdf5.h5array(magic(5));

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:32 $ 
%   Copyright 1984-2002 The MathWorks, Inc.

if (nargin == 1)
    hObj = hdf5.h5array;
    hObj.setData(varargin{1});
elseif (nargin == 0)
    hObj = hdf5.h5array;
else
    error('MATLAB:h5array:h5array:tooManyInputs', ...
          'Too many arguments to constructor.')
end
