function setData(hObj, data)
%SETDATA  Set the hdf5.h5vlen's data.
%
%   HDF5VLEN = hdf5.h5vlen;
%   HDF5VLEN.setData({0:5 0:10});

%   Copyright 1984-2002 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end

if (numel(data) ~= length(data))
    error('Data must be a vector.')
   
    if (((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type'))) && ...
        (~iscell(data)))
        error('Data must be numeric or a subclass of hdf5type or a cell.')
    end

else
  if (isa(data, class(data(1))))
    if iscell(data)
        hObj.Data = cell2mat(data);
    else
        hObj.Data = data;
    end
  else
    error('All data elements must be of the same type.')
  end
end
