function schema
%SCHEMA  Definition of an hdf5.h5string object.

%   Copyright 1984-2002 The MathWorks, Inc.

package = findpackage('hdf5');
parent = findclass(package, 'hdf5type');

c = schema.class(package, 'h5string', parent);

p = schema.prop(c, 'Length', 'double');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';

p = schema.prop(c, 'Padding', 'string');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';

p = schema.prop(c, 'Data', 'string');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';
