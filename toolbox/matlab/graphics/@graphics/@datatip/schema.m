function schema

% Copyright 2002-2004 The MathWorks, Inc.

% Construct class
pk = findpackage('graphics');
hgpk = findpackage('hg');
grpclass = hgpk.findclass('hggroup');

cls = schema.class(pk,'datatip',grpclass);


% Add new enumeration type
if (isempty(findtype('OrientationType')))
  schema.EnumType('OrientationType',{'top-right','top-left',...
                      'bottom-left','bottom-right'});
end

% Add new enumeration type
if (isempty(findtype('ModeType')))
  schema.EnumType('ModeType',{'manual','auto'});
end

% Add new enumeration type
if (isempty(findtype('DatatipStyle')))
  schema.EnumType('DatatipStyle',{'marker','datatip'});
end


% PUBLIC

% These font properties pass through to the underlying
% text object
p = schema.prop(cls, 'FontAngle','string');
set(p,'FactoryValue','normal');
p = schema.prop(cls, 'FontName','string');
set(p,'FactoryValue','Helvetica');
p = schema.prop(cls, 'FontSize','double');
set(p,'FactoryValue',8);
p = schema.prop(cls, 'FontUnits','string');
set(p,'FactoryValue','points');
p = schema.prop(cls, 'FontWeight','string');
set(p,'FactoryValue','normal');
p = schema.prop(cls, 'EdgeColor','MATLAB array');
set(p,'FactoryValue',[.8 .8 .8]);
p = schema.prop(cls, 'BackgroundColor','MATLAB array');
set(p,'FactoryValue',[1 1 238/255]); % light yellow
p = schema.prop(cls, 'TextColor','MATLAB array');
set(p,'FactoryValue',[0 0 0]);

% These marker properties pass through to the underlying
% line object
p = schema.prop(cls, 'Marker','MATLAB array');
set(p,'FactoryValue','square');
p = schema.prop(cls, 'MarkerSize','MATLAB array');
set(p,'FactoryValue',10);
p = schema.prop(cls, 'MarkerEdgeColor','MATLAB array');
set(p,'FactoryValue',[1 1 220/255]);
p = schema.prop(cls, 'MarkerFaceColor','MATLAB array');
set(p,'FactoryValue',[0 0 0]);
p = schema.prop(cls, 'MarkerEraseMode','MATLAB array');
set(p,'FactoryValue','normal');

p = schema.prop(cls, 'Position', 'MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls, 'Draggable','on/off');
set(p,'FactoryValue','on');

schema.prop(cls, 'String','MATLAB array'); % string or cell array
p = schema.prop(cls, 'Visible','on/off');
set(p,'FactoryValue','off');

%ToDo: replace 'StringFcn' with 'UpdateFcn'
schema.prop(cls, 'StringFcn','MATLAB array');
schema.prop(cls, 'UpdateFcn','MATLAB array');

% Context Menu
schema.prop(cls, 'UIContextMenu','handle');

schema.prop(cls, 'Host', 'handle');

p = schema.prop(cls, 'Interpolate','on/off');
set(p,'FactoryValue','off');

% PRIVATE
p = schema.prop(cls, 'ViewStyle','DatatipStyle');
set(p,'FactoryValue','datatip');
set(p,'Visible','off');

p = schema.prop(cls, 'OrientationMode','ModeType');
set(p,'FactoryValue','auto');
set(p,'Visible','off');

p = schema.prop(cls, 'Orientation','OrientationType');
set(p,'FactoryValue','top-right');
set(p,'Visible','off');

p = schema.prop(cls,'HostAxes','handle');
p.Visible = 'off';

p = schema.prop(cls,'IsDeserializing','MATLAB array'); % true/false
p.Visible = 'off';
p.FactoryValue = false;

p = schema.prop(cls,'DoThrowStartDragEvent','MATLAB array'); %
p.Visible = 'off';
p.FactoryValue = true;
                                                          
p = schema.prop(cls,'EnableZStacking','MATLAB array'); % true/false
p.Visible = 'off';
p.FactoryValue = false;

p = schema.prop(cls,'EnableAxesStacking','MATLAB array'); % true/false
p.Visible = 'off';
p.FactoryValue = false;

p = schema.prop(cls,'ZStackMinimum','MATLAB array');
p.Visible = 'off';
p.FactoryValue = 1;

p = schema.prop(cls,'EmptyArgUpdateFcn','MATLAB array');
p.Visible = 'off';

p = schema.prop(cls, 'PixelOffset','MATLAB array');
p.Visible = 'off';
p.FactoryValue = [10,10];

p = schema.prop(cls, 'MarkerHandle', 'MATLAB array');
p.Visible = 'off';
p = schema.prop(cls, 'MarkerHandleButtonDownFcn','MATLAB array');
p.Visible = 'off';

p = schema.prop(cls, 'TextBoxHandle', 'handle');
p.Visible = 'off';
p = schema.prop(cls, 'TextBoxHandleButtonDownFcn','MATLAB array');
p.Visible = 'off';

p = schema.prop(cls, 'DataCursorHandle', 'handle');
p.Visible = 'off';

p = schema.prop(cls, 'DatatipManagerHandle', 'handle');
p.Visible = 'off';

p = schema.prop(cls, 'SelfListenerHandles', 'handle vector');
p.Visible = 'off';

p = schema.prop(cls, 'HostListenerHandles', 'handle vector');
p.Visible = 'off';

p = schema.prop(cls, 'ExternalListenerHandles', 'handle vector');
p.Visible = 'off';

p = schema.prop(cls, 'OrientationPropertyListener', 'handle vector');
p.Visible = 'off';

p = schema.prop(cls, 'Invalid','double'); % logical
p.Visible = 'off';
p.FactoryValue = logical(0);

p = schema.prop(cls, 'uistate','MATLAB array'); % logical
p.Visible = 'off';

p = schema.prop(cls, 'Version','MATLAB array'); % logical
p.Visible = 'off';
p.FactoryValue = version;

% Workaround: Flicker occurs during dragging if no double buffer
p = schema.prop(cls, 'OriginalDoubleBufferState','on/off');
p.Visible = 'off';

% ...for debugging
p = schema.prop(cls, 'Debug','double'); % logical
p.Visible = 'off';
p.FactoryValue = true;

% EVENTS
evd = schema.event(cls,'BeginDrag');
evd = schema.event(cls,'EndDrag');
evd = schema.event(cls,'UpdateCursor');
