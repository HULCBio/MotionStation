function schema
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   file: @imviewpkg/@image/schema.m
%
%   Schema file for UDD object representing a Matlab image array  %
%
%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision.1.4.1 $ $Date: 2003/05/03 17:51:30 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get the package handles which we will need
pkg = findpackage('imviewpkg');  %our package

%Create a new schema object to represent our class.
%Pass the package to which the class belongs, the class
%name.  Since we are not deriving from another class,
%we will not have to supply a parent class from the 
%class hierarchy.

c = schema.class(pkg,'image');

%Add properties to our class
p = schema.prop(c, 'name',          'string');
p = schema.prop(c, 'imagetype',     'string');
p = schema.prop(c, 'width',         'double');
p = schema.prop(c, 'height',        'double');
p = schema.prop(c, 'classtype',     'string');
p = schema.prop(c, 'minvalue',      'double');
p = schema.prop(c, 'maxvalue',      'double');
p = schema.prop(c, 'displayblack',  'double');
p = schema.prop(c, 'displaywhite',  'double');
p = schema.prop(c, 'scalerangemin', 'double');
p = schema.prop(c, 'scalerangemax', 'double');
p = schema.prop(c, 'allintegers',   'bool');
p = schema.prop(c, 'magnification', 'string');

% jmetadata is a handle to a java class specified in image.m
p = schema.prop(c, 'jmetadata',     'handle');
