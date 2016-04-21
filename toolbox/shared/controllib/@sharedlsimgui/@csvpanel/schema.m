function schema
% SCHEMA  Defines properties for @csvpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:32 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'csvpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'csvsheet','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');