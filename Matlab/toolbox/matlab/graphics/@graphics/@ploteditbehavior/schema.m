function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'ploteditbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Plotedit';

% Indicates if an object is dragable and resizeable
p = schema.prop(cls,'EnableMove','MATLAB array');
p.FactoryValue = true;

% Indicates if an object is dragable by clicking in the interior
p = schema.prop(cls,'AllowInteriorMove','MATLAB array');
p.FactoryValue = false;

% Indicates if an object is selectable
p = schema.prop(cls,'EnableSelect','MATLAB array');
p.FactoryValue = true;

% Callback for mouse-over cursor control
p = schema.prop(cls,'MouseOverFcn','MATLAB array');
p.FactoryValue = [];

% Callback for plot-edit button down
p = schema.prop(cls,'ButtonDownFcn','MATLAB array');
p.FactoryValue = [];

% Callback for plot-edit button up
p = schema.prop(cls,'ButtonUpFcn','MATLAB array');
p.FactoryValue = [];

% Indicates object should keep context menu in plotedit mode
p = schema.prop(cls,'KeepContextMenu','MATLAB array');
p.FactoryValue = false;

% Callback for plot-edit mouse movement - set this when you
% need custom motion or drag events while in plotedit mode.
p = schema.prop(cls,'MouseMotionFcn','MATLAB array');
p.FactoryValue = [];

% Indicates if an object is visible to plotedit - overrides all
% above settings
p = schema.prop(cls,'Enable','MATLAB array');
p.FactoryValue = true;

listener = handle.listener(cls,p,'PropertyPostSet',@doEnableAction);
setappdata(0,'PloteditBehaviorEnableListener',listener);

function doEnableAction(hSrc, eventData)
h = eventData.affectedObject;
set(h,'EnableSelect',get(h,'Enable'));
set(h,'EnableMove',get(h,'Enable'));


