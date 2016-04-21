function schema
% SCHEMA  Defines properties for @importselector class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:45 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'importselector');

% Properties

% Last import type (ws,xls etc)  Defines which panel etc should be displayed on Data import ...
schema.prop(c, 'filetype','string');
% Strucure of java handles describing import GUI frame
schema.prop(c, 'importhandles', 'MATLAB array');
% Handle to the UDD object representing the Excel sheet table
schema.prop(c, 'excelpanel', 'handle');
% workspace @varbrowser
schema.prop(c, 'workpanel', 'handle');
% matfile browser @varbrowser
schema.prop(c, 'matpanel', 'handle');
% Handle to the UDD object representing the CSV sheet table
schema.prop(c, 'csvpanel', 'handle');
% Handle to the UDD object representing the ASC sheet table
schema.prop(c, 'ascpanel', 'handle');
% Handle of the parent importtable
schema.prop(c, 'importtable', 'handle');
% Copied data structure
schema.prop(c, 'Visible',    'on/off');  
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');


