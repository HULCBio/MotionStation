function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'datacursorbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'DataCursor';

p = schema.prop(cls,'StartDragFcn','MATLAB array');
p = schema.prop(cls,'EndDragFcn','MATLAB array');
p = schema.prop(cls,'UpdateFcn','MATLAB array');
p = schema.prop(cls,'CreateFcn','MATLAB array');
p = schema.prop(cls,'CreateNewDatatip','MATLAB array');
p.FactoryValue = false;
p.Description = 'True will create a new datatip for every mouse click';
p = schema.prop(cls,'Enable','MATLAB array');
p.FactoryValue = true;


