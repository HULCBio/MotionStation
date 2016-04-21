function schema
%SCHEMA  Definition of @dataview interface (abstract plot component).
%
%  This class holds both the data and the view objects for each plot
%  component.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:06 $

% Register class 
pkg = findpackage('wrfc');
c = schema.class(pkg, 'dataview');

% Public attributes
schema.prop(c, 'Data',    'handle vector');  % Data objects (@data)
schema.prop(c, 'DataFcn', 'MATLAB array');   % Function for updating data
schema.prop(c, 'Description', 'string');     % Component description
schema.prop(c, 'Parent',  'handle');         % Parent object
p = schema.prop(c, 'RefreshMode', 'string'); % Graphics update mode
p.FactoryValue = 'normal';                   % RefreshMode: [{normal} | quick]
p.SetFunction = @LocalRefreshMode;
schema.prop(c, 'View',    'handle vector');  % View objects (@view)
p = schema.prop(c, 'Visible', 'on/off');     % Visibility of overall component
p.FactoryValue = 'on';                    

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

% Local Functions

% ----------------------------------------------------------------------------%
% Purpose: Implement RefreshMode=quick
% ----------------------------------------------------------------------------%
function Value = LocalRefreshMode(this,Value)
% SetFunctin for RefreshMode property
% Set G-objects' EraseMode 
if strcmp(Value,'normal')
   EraseMode = 'normal';
else
   EraseMode =  'xor';
end
for v=this.View'
   h = ghandles(v);
   set(h(ishandle(h)), 'EraseMode', EraseMode);
end

