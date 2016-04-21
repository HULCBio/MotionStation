function schema
% SCHEMA  Defines properties for @exceltable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:42 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('sharedlsimgui'), 'exceltable', superclass);

% Properties
schema.prop(c, 'filename','MATLAB array');   
schema.prop(c, 'sheetname','MATLAB array');   
schema.prop(c, 'numdata','MATLAB array');  