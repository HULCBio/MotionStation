function schema

% Copyright 2002-2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'zoom');

% Add new enumeration type
if isempty(findtype('ZoomConstraint'))
  schema.EnumType('ZoomConstraint',{'none','horizontal','vertical'});
end

% Add new enumeration type
if isempty(findtype('in/out'))
  schema.EnumType('in/out',{'in','out'});
end

% Property for storing the figure handle
p = schema.prop(cls, 'FigureHandle','handle');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'Constraint','ZoomConstraint');
p.FactoryValue = 'none';

p = schema.prop(cls,'Direction','in/out');                      
p.FactoryValue = 'in';

p = schema.prop(cls,'IsOn','MATLAB array');
p.FactoryValue = false;

p = schema.prop(cls,'UIContextMenu','handle');

%-----HIDDEN PROPERTIES----%
p = schema.prop(cls,'Target','handle');
p.Visible = 'off';

p = schema.prop(cls,'Debug','on/off');
p.FactoryValue = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(cls,'MaxViewAngle','double');
p.FactoryValue = 25;
p.Visible = 'off';

% Property for holding the RBBOX lines.
p = schema.prop(cls, 'LineHandles','MATLAB array');

% Property holding the axes handles of the last zoomed-in axes
p = schema.prop(cls, 'CurrentAxes','MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls, 'MousePoint','MATLAB array');
p.Visible = 'off';

p = schema.prop(cls, 'CameraViewAngle','MATLAB array');
p.Visible = 'off';

p = schema.prop(cls,'ContextMenuHandle','handle');
p.Visible = 'off';
