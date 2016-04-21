function schema
% @graph2d/@constantlineseries/schema.m   Define the schema for this UDD object.
%
% See also @graph2d/@constantlineseries/constantlineseries.m

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 00:00:34 $

lineseries('init'); % make sure graph2d.lineseries is registered with UDD

pkg = findpackage('graph2d'); % get handle to graph2d package

% Create a new subclass of the lineseries object
c = schema.class(pkg, 'constantlineseries', pkg.findclass('lineseries'));
% Add hidden property 'Constant'
% Must be a scalar constant value.
p = schema.prop(c, 'Value', 'NReals');  % could be a vector  
p.AccessFlags.PublicSet = 'off';

% Add hidden property DependVar to name dependent variable
% if 'y' then ydata = fun(xdata)  (default horizontal)
% if 'x' then xdata = fun(ydata)  (vertical)
p = schema.prop(c, 'DependVar', 'String');
p.AccessFlags.PublicSet = 'off';            
p.AccessFlags.Init = 'on';
p.FactoryValue = 'y';
% Listeners for Public Properties:
% Add a private property called 'listenerAxes' to hold onto the
% axes listener.  Listener will automatically get destroyed
% when the object is destroyed.
p = schema.prop(c, 'listenerAxes', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Add a private property called 'listenerValue' to hold onto the
% Value listener.  Listener will automatically get destroyed
% when the object is destroyed.
p = schema.prop(c, 'listenerValue', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

