function schema
% SCHEMA  Defines properties for @asctable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:29 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('sharedlsimgui'), 'asctable', superclass);

% Properties

schema.prop(c, 'filename','string');   
schema.prop(c, 'delimeter','string');   
schema.prop(c, 'numdata','MATLAB array');  

