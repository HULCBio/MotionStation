function schema
%  SCHEMA  Defines properties for @ltiviewer class

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2004/04/10 23:14:42 $

% Find parent package
pkg = findpackage('viewgui');

% Find parent class (superclass)
supclass = findclass(pkg, 'viewer');

% Register class (subclass)
c = schema.class(pkg, 'ltiviewer', supclass);
c.Description = 'Extends the viewer class to display and organize the lti responses';

% Class attributes
%%%%%%%%%%%%%%%%%%%
% @ltisource object
sys = schema.prop(c, 'Systems',         'handle vector');
sys.Description = 'resppack.ltisource object created from an @lti object.';
% @style 
sty = schema.prop(c, 'Styles',    'handle vector'); 
sty.Description = 'Styles attached to each system object';

% Private Properties
% I/O Names of all Systems in Viewer
io(1) = schema.prop(c, 'InputNames',    'string vector');
io(2) = schema.prop(c, 'OutputNames',   'string vector');
set(io,'FactoryValue',{''},'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');

% Events
schema.event(c,'SystemChanged');    % Change in Systems list
schema.event(c,'ModelImport');      % New systems imported or existing systems refreshed
