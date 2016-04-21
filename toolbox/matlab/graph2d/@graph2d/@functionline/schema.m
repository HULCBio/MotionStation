function schema
% @graph2d/@functionline/schema.m   Schema for this UDD object.
%
% See also @graph2d/@functionline/functionline.m

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2004/04/06 21:52:59 $

lineseries('init'); % make sure graph2d.lineseries is registered with UDD

pkg = findpackage('graph2d'); % get handle to graph2d package

% Create a new subclass of the lineseries object
c = schema.class(pkg, 'functionline', pkg.findclass('lineseries'));

% Add hidden property 'Function'
% Must be function, e.g. inline object, function handle,
%   or name (string) of function
p = schema.prop(c, 'Function', 'mxArray');  
p.AccessFlags.PublicSet = 'off';            % No listener since not settable

% Add visible property Granularity
% which determines how many data points are used
p = schema.prop(c, 'Granularity', 'int');
p.AccessFlags.PublicSet = 'on';             % Listener created below
p.AccessFlags.Init = 'on';
p.FactoryValue = 300;

% Add visible property UserArgs
% because some functions have extra params: fun(xdata, UserArgs{:})
p = schema.prop(c, 'UserArgs', 'mxArray');
p.AccessFlags.PublicSet = 'on';             % Listener created below
p.AccessFlags.Init = 'on';
p.FactoryValue = {};


% Listeners for Public Properties:

% Add a private property called 'listenerAxes' to hold onto the
% axes listener.  Listener will automatically get destroyed
% when the object is destroyed.
p = schema.prop(c, 'listenerAxes', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Add a private property called 'listenerUserArgs' to hold onto the
% userargs listener.  Listener will automatically get destroyed
% when the object is destroyed.
p = schema.prop(c, 'listenerUserArgs', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Add a private property called 'listenerGranularity' to hold onto the
% granularity listener.  Listener will automatically get destroyed
% when the object is destroyed.
p = schema.prop(c, 'listenerGranularity', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
