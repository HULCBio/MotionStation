function schema
%SCHEMA  Definition of compound object.

package = findpackage('hdf5');
parent = findclass(package, 'hdf5type');

c = schema.class(package, 'h5compound', parent);

p = schema.prop(c, 'MemberNames', 'MATLAB array');
%p.AccessFlags.PublicGet='off';
p.AccessFlags.PublicSet='off';
