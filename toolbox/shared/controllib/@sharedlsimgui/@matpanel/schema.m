function schema
% SCHEMA  Defines properties for @matpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:49 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'matpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'matbrowser','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');