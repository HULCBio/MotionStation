function schema
% SCHEMA  Defines properties for @ascpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:26 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'ascpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'ascsheet','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');