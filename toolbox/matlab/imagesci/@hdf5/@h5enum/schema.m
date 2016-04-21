function schema
%SCHEMA  Definition of hdf5.h5enum object.

%   Copyright 1984-2002 The MathWorks, Inc.

package = findpackage('hdf5');
parent = findclass(package, 'hdf5type');

c = schema.class(package, 'h5enum', parent);

p = schema.prop(c, 'EnumNames', 'MATLAB array');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';

p = schema.prop(c, 'EnumValues', 'MATLAB array');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';

