function schema

%   Copyright 1984-2004 The MathWorks, Inc. 

pk = findpackage('graphics');
cls = schema.class(pk,'datacursor');

% Add new tracking type
if (isempty(findtype('TrackingType')))
  schema.EnumType('TrackingType',{'x','y','auto'});
end

% PUBLIC
schema.prop(cls,'Position','MATLAB array');
schema.prop(cls,'Target','handle');

% PRIVATE
% Flag for performance optimization
p = schema.prop(cls,'InternalListeners','handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(cls,'TargetHasUpdateDataCursorMethod','double'); % true/false
set(p,'FactoryValue',false);
set(p,'Visible','off');

% Cache for performance optimization
p = schema.prop(cls,'UpdateFcnCache','MATLAB array'); % cell or function_handle
set(p,'Visible','off');

% Flag for performance optimization
p = schema.prop(cls,'TargetHasGetDatatipTextMethod','double'); % true/false
set(p,'FactoryValue',false);
set(p,'Visible','off');

p = schema.prop(cls,'InternalListeners','MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls,'Debug','double'); % true/false
set(p,'FactoryValue',false);
set(p,'Visible','off');

p = schema.prop(cls,'Interpolate','on/off');
set(p,'FactoryValue','off');
set(p,'Visible','off');

p = schema.prop(cls,'DataIndex','MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls,'InterpolationFactor','MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls,'Tracking','TrackingType');
set(p,'Visible','off');
set(p,'FactoryValue','auto');