function schema
%SCHEMA  Definition of an hdf5.h5vlen object.

%   Copyright 1984-2002 The MathWorks, Inc.

package = findpackage('hdf5');
parent = findclass(package, 'hdf5type');

c = schema.class(package, 'h5vlen', parent);
 
