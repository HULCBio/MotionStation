function schema
%SCHEMA  Definition of an hdf5.hdf5type object.

%   Copyright 1984-2002 The MathWorks, Inc.

pk = findpackage('hdf5');

% If we are inheriting from a common ancestor, we would use that ancestor
% in our classes below.

c = schema.class(pk, 'hdf5type');

p = schema.prop(c, 'Name', 'string');

p = schema.prop(c, 'Data', 'MATLAB array');

