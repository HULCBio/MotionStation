function schema

% Copyright 2003 The MathWorks, Inc.

% Construct class
pk = findpackage('graphics');

hgpk = findpackage('hg');
grpclass = hgpk.findclass('hggroup');

cls = schema.class(pk,'cursorbar',grpclass);

% Add new enumeration type
if (isempty(findtype('CursorbarOrientation')))
  schema.EnumType('CursorbarOrientation',{'vertical','horizontal'});
end

% Target - a single line
p = schema.prop(cls, 'Target', 'handle vector');

p = schema.prop(cls,'TargetXData','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'TargetYData','MATLAB array');
p.Visible = 'off';

% line object used to represent the cursor bar
p = schema.prop(cls,'CursorLineHandle','handle');
p.Visible = 'off';

p = schema.prop(cls,'CursorLineColor','MATLAB array');
p.FactoryValue = [0 0 0];

p = schema.prop(cls,'CursorLineStyle','MATLAB array');

p = schema.prop(cls,'CursorLineWidth','MATLAB array');
p.FactoryValue = 1;


% line objects used to represent the intersection points with the Target
p = schema.prop(cls, 'TargetMarkerHandle','handle vector');
p.Visible = 'off';

p = schema.prop(cls, 'TargetMarkerStyle','MATLAB array');
p.FactoryValue = 'square';

p = schema.prop(cls, 'TargetMarkerSize','MATLAB array');
p.FactoryValue = 8;

p = schema.prop(cls, 'TargetMarkerEdgeColor','MATLAB array');
p.FactoryValue = [0 0 0];

p = schema.prop(cls, 'TargetMarkerFaceColor','MATLAB array');
p.FactoryValue = 'none';

% line objects used to create larger drag surfaces for cursor line
p = schema.prop(cls,'TopHandle','handle');
p = schema.prop(cls,'TopMarker','MATLAB array');
p.FactoryValue = 'v';

p = schema.prop(cls,'BottomHandle','handle');
p = schema.prop(cls,'BottomMarker','MATLAB array');
p.FactoryValue = '^';


p = schema.prop(cls,'ButtonDownFcn','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% af = get(p,'AccessFlags');
% af.PublicSet = 'off';
% af.PublicGet = 'off';
% set(p,'AccessFlags',af);


% object(s) used to display information about intersection point(s)
% could be TEXT, UICONTROL, or other
p = schema.prop(cls,'DisplayHandle','handle vector');

p = schema.prop(cls,'ShowText','on/off');
p.FactoryValue = 'on';

%%% ??? need to replace StringFcn
% p = schema.prop(cls,'StringFcn','MATLAB array');
p = schema.prop(cls,'UpdateFcn','MATLAB array');

% Position is used to set the location of main Marker for the intersection
p = schema.prop(cls,'Position','MATLAB array');
p.Visible = 'off';

% Location is a single value which is used to set the Position, based on the
% Orientation
p = schema.prop(cls,'Location','MATLAB array');

%??? not used yet
% p = schema.prop(cls, 'Draggable','on/off');
% p.FactoryValue='on';

% Context Menu
schema.prop(cls, 'UIContextMenu','handle');

% data cursor
p = schema.prop(cls, 'DataCursorHandle', 'handle');

% orientation: vertical or horizontal
p = schema.prop(cls,'Orientation','CursorbarOrientation');
p.FactoryValue = 'vertical';

% space to store current WindowButton...Fcns
p = schema.prop(cls,'FigureCallbacks','MATLAB array');

% store listeners for cursor bar
p = schema.prop(cls, 'SelfListenerHandles', 'handle vector');
p.Visible = 'off';

% store listeners for Target
p = schema.prop(cls, 'TargetListenerHandles', 'handle vector');
p.Visible = 'off';

% store other external listeners
p = schema.prop(cls, 'ExternalListenerHandles', 'handle vector');
p.Visible = 'off';

% Debugging
p = schema.prop(cls, 'Debug','double'); % logical
p.Visible = 'off';
p.FactoryValue = logical(0);

% Events
schema.event(cls,'BeginDrag');
schema.event(cls,'EndDrag');
schema.event(cls,'UpdateCursorBar');

