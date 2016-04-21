function schema

% Copyright 2003-2004 The MathWorks, Inc.

% Class
pk = findpackage('graphics');
cls = schema.class(pk,'datacursormanager');

% Enumeration
if (isempty(findtype('DataCursorDisplayStyle')))
  schema.EnumType('DataCursorDisplayStyle',{'datatip','window'});
end

% Public Properties
p = schema.prop(cls,'Enable','on/off');
p.FactoryValue = 'off';
p = schema.prop(cls,'SnapToDataVertex','on/off');
p.FactoryValue = 'on';
p = schema.prop(cls,'DisplayStyle','DataCursorDisplayStyle');
p.FactoryValue = 'datatip';
p = schema.prop(cls,'UpdateFcn','MATLAB array');

% Public Read Only
p = schema.prop(cls,'Figure','handle');
p.AccessFlags.PublicSet = 'off';

% Private Listeners
p = schema.prop(cls,'InternalListeners','handle vector');
p.Visible = 'off';

p = schema.prop(cls,'ExternalListeners','handle vector');
p.Visible = 'off';

% Private Properties

p = schema.prop(cls,'EnableAxesStacking','MATLAB array'); %true/false
set(p,'FactoryValue',false); 
set(p,'Visible','off');

p = schema.prop(cls,'EnableZStacking','MATLAB array'); %true/false
set(p,'FactoryValue',true);
set(p,'Visible','off');
p = schema.prop(cls,'ZStackMinimum','MATLAB array'); 
set(p,'FactoryValue',1);
p.Visible = 'off';
p = schema.prop(cls,'HiddenUpdateFcn','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'DataCursors','handle vector'); 
p.Visible = 'off';
p = schema.prop(cls,'UIState','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'CurrentDataCursor','handle');
p.Visible = 'off';
p = schema.prop(cls,'OriginalRenderer','string');
p.Visible = 'off';
p = schema.prop(cls,'OriginalRendererMode','string');
p.Visible = 'off';
p = schema.prop(cls,'UIContextMenu','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'PanelHandle','handle');
p.Visible = 'off';
p = schema.prop(cls,'PanelDatatipHandle','handle');
p.Visible = 'off';
p = schema.prop(cls,'DefaultExportVarName','string');
p.Visible = 'off';
set(p,'FactoryValue','cursor_info');
p = schema.prop(cls,'DefaultPanelPosition','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'NewDataCursorOnClick','MATLAB array'); % logical
p.Visible = 'off';
p.FactoryValue = false;

% ...for debugging
p = schema.prop(cls,'Debug','double');
p.FactoryValue = false;
p.Visible = 'off';

% Events
schema.event(cls,'UpdateDataCursor');
hEvent = schema.event(cls,'MouseMotion');
hEvent = schema.event(cls,'ButtonDown');
