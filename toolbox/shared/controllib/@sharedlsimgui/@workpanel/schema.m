function schema
% SCHEMA  Defines properties for @workpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:17 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'workpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'workbrowser','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');