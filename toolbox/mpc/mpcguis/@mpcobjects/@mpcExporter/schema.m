function schema

% SCHEMA  Defines properties for @mpcExporter class

% Author(s): Larry Ricker
% Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:40 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'mpcExporter');

% Properties
   
schema.prop(c, 'Handles','MATLAB array');
schema.prop(c, 'Tasks', 'MATLAB array');
schema.prop(c, 'SelectedRoot','handle');
schema.prop(c, 'CurrentController', 'handle');

