function schema
%  SCHEMA  Defines properties for LinOptionsDialog class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/04 02:38:07 $

% Find parent package
pkg = findpackage('jDialogs');

% Register class (subclass) in package
c = schema.class(pkg, 'LinOptionsDialog');

% Properties
schema.prop(c, 'JavaHandles', 'MATLAB array');
schema.prop(c, 'JavaPanel', 'MATLAB array');
schema.prop(c, 'TaskNode', 'MATLAB array');